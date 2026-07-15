import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question_set_draft.dart';
import '../models/submission_confirmation.dart';
import 'contribution_repository.dart';

class ApiContributionRepository implements ContributionRepository {
  ApiContributionRepository({required String baseUrl, http.Client? client})
    : _baseUri = _parseBaseUrl(baseUrl),
      _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  @override
  Future<SubmissionConfirmation> submitForReview(QuestionSetDraft draft) async {
    final response = await _client.post(
      _baseUri.resolve('learning/question-set-submissions/submit'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(draft.toJson()),
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
