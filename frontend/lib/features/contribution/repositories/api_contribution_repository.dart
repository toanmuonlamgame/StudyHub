import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_request.dart';
import '../../../core/access_token_provider.dart';
import '../models/question_set_draft.dart';
import '../models/contribution_submission.dart';
import '../models/question_draft.dart';
import '../models/answer_option_draft.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';

class ApiContributionRepository implements ContributionRepository {
  ApiContributionRepository({
    required String baseUrl,
    http.Client? client,
    this.accessTokenProvider,
    this.requestTimeout = defaultApiRequestTimeout,
  }) : _baseUri = _parseBaseUrl(baseUrl),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;
  final AccessTokenProvider? accessTokenProvider;

  @override
  Future<List<ContributionSubmission>> listSubmissions() async {
    final response = await withApiTimeout(
      _client.get(
        _baseUri.resolve('learning/question-set-submissions'),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response);
    final submissions = body['submissions'];
    if (submissions is! List) {
      throw const ContributionSubmissionException('Malformed submission list.');
    }
    return submissions
        .map((item) => _submissionFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ContributionSubmission> createDraft(QuestionSetDraft draft) =>
      _writeDraft('POST', 'learning/question-set-submissions', draft);

  @override
  Future<ContributionSubmission> updateDraft(
    String submissionId,
    QuestionSetDraft draft,
  ) => _writeDraft(
    'PUT',
    'learning/question-set-submissions/${Uri.encodeComponent(submissionId)}',
    draft,
  );

  @override
  Future<void> deleteDraft(String submissionId) async {
    final response = await withApiTimeout(
      _client.delete(
        _baseUri.resolve(
          'learning/question-set-submissions/${Uri.encodeComponent(submissionId)}',
        ),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    if (response.statusCode != 204) _decodeResponse(response);
  }

  @override
  Future<SubmissionConfirmation> submitDraftForReview(
    String submissionId,
  ) async {
    final response = await withApiTimeout(
      _client.post(
        _baseUri.resolve(
          'learning/question-set-submissions/${Uri.encodeComponent(submissionId)}/submit',
        ),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    final submission = _readSubmission(_decodeResponse(response));
    return SubmissionConfirmation(
      id: submission.id,
      status: 'pendingReview',
      title: submission.draft.title,
    );
  }

  @override
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  }) async {
    final response = await withApiTimeout(
      _client.post(
        _baseUri.resolve('learning/question-set-submissions/submit'),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
        body: jsonEncode({'submissionId': submissionId, ...draft.toJson()}),
      ),
      requestTimeout,
    );
    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      if (error is Map<String, dynamic> &&
          error['code'] == 'SUBMISSION_VALIDATION_FAILED' &&
          error['fields'] is List) {
        final issues = (error['fields'] as List)
            .whereType<Map<String, dynamic>>()
            .map(
              (field) => DraftValidationIssue(
                field['path'] as String? ?? 'submission',
                field['message'] as String? ?? 'Invalid value.',
              ),
            )
            .toList(growable: false);
        if (issues.isNotEmpty) {
          throw ContributionValidationException(issues);
        }
      }
      throw ContributionSubmissionException(
        'Submission failed with status ${response.statusCode}.',
      );
    }
    final submission = decoded['submission'];
    if (submission is! Map<String, dynamic>) {
      throw const ContributionSubmissionException(
        'Malformed submission response.',
      );
    }
    final id = submission['id'];
    final status = submission['status'];
    final title = submission['title'];
    if (id is! String || status != 'pendingReview' || title is! String) {
      throw const ContributionSubmissionException(
        'Malformed submission response.',
      );
    }
    return SubmissionConfirmation(id: id, status: status, title: title);
  }

  Future<ContributionSubmission> _writeDraft(
    String method,
    String path,
    QuestionSetDraft draft,
  ) async {
    final headers = await authenticatedJsonHeaders(accessTokenProvider);
    final uri = _baseUri.resolve(path);
    final body = jsonEncode(draft.toJson());
    final response = await withApiTimeout(
      method == 'POST'
          ? _client.post(uri, headers: headers, body: body)
          : _client.put(uri, headers: headers, body: body),
      requestTimeout,
    );
    return _readSubmission(_decodeResponse(response));
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['fields'] is List) {
        final issues = (error['fields'] as List)
            .whereType<Map<String, dynamic>>()
            .map(
              (field) => DraftValidationIssue(
                field['path'] as String? ?? 'submission',
                field['message'] as String? ?? 'Invalid value.',
              ),
            )
            .toList(growable: false);
        if (issues.isNotEmpty) throw ContributionValidationException(issues);
      }
      throw ContributionSubmissionException(
        'Request failed with status ${response.statusCode}.',
      );
    }
    return decoded;
  }

  static ContributionSubmission _readSubmission(Map<String, dynamic> body) {
    final value = body['submission'];
    if (value is! Map<String, dynamic>) {
      throw const ContributionSubmissionException(
        'Malformed submission response.',
      );
    }
    return _submissionFromJson(value);
  }

  static ContributionSubmission _submissionFromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    if (rawQuestions is! List) {
      throw const ContributionSubmissionException(
        'Malformed submission questions.',
      );
    }
    final questions = <QuestionDraft>[];
    for (
      var questionIndex = 0;
      questionIndex < rawQuestions.length;
      questionIndex++
    ) {
      final question = rawQuestions[questionIndex] as Map<String, dynamic>;
      final rawOptions = question['answerOptions'] as List;
      questions.add(
        QuestionDraft(
          id: 'submission-question-$questionIndex',
          text: question['text'] as String,
          explanation: question['explanation'] as String? ?? '',
          answerOptions: [
            for (
              var optionIndex = 0;
              optionIndex < rawOptions.length;
              optionIndex++
            )
              AnswerOptionDraft(
                id: 'submission-answer-$questionIndex-$optionIndex',
                text:
                    (rawOptions[optionIndex] as Map<String, dynamic>)['text']
                        as String,
                isCorrect:
                    (rawOptions[optionIndex]
                            as Map<String, dynamic>)['isCorrect']
                        as bool,
              ),
          ],
        ),
      );
    }
    final status = json['status'] as String;
    return ContributionSubmission(
      id: json['id'] as String,
      status: switch (status) {
        'draft' => ContributionStatus.draft,
        'pendingReview' => ContributionStatus.pendingReview,
        'published' => ContributionStatus.approved,
        'rejected' => ContributionStatus.rejected,
        _ => throw const ContributionSubmissionException(
          'Unknown submission status.',
        ),
      },
      draft: QuestionSetDraft(
        subjectId: json['subjectId'] as String,
        topicId: json['topicId'] as String?,
        title: json['title'] as String,
        description: json['description'] as String,
        questions: questions,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> _decodeObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Converted to a stable repository error below.
    }
    throw const ContributionSubmissionException('Malformed server response.');
  }

  static Uri _parseBaseUrl(String baseUrl) {
    final value = baseUrl.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Must be an absolute URL.');
    }
    return Uri.parse(value.endsWith('/') ? value : '$value/');
  }
}
