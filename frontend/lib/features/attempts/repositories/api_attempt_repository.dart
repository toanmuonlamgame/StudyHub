import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_request.dart';
import '../../../core/access_token_provider.dart';
import '../../learning/repositories/learning_result_json_mapper.dart';
import '../models/exam_attempt.dart';
import 'attempt_repository.dart';

class ApiAttemptRepository extends AttemptRepository {
  ApiAttemptRepository({
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
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Future<ExamAttemptDetail> saveExamAttempt(
    ExamAttemptSaveRequest request,
  ) async {
    final response = await withApiTimeout(
      _client.post(
        _endpoint(
          'learning/question-sets/${Uri.encodeComponent(request.questionSetId)}/attempts',
        ),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
        body: jsonEncode({
          'submissionId': request.submissionId,
          'startedAt': request.startedAt.toUtc().toIso8601String(),
          'selectedAnswerOptionIdsByQuestionId':
              request.selectedAnswerOptionIdsByQuestionId,
        }),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response, 'saveExamAttempt');
    final attempt = _attemptDetailFromJson(_readObject(body, 'attempt'));
    notifyListeners();
    return attempt;
  }

  @override
  Future<List<ExamAttemptSummary>> listExamAttempts() async {
    final response = await withApiTimeout(
      _client.get(
        _endpoint('learning/attempts'),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response, 'listExamAttempts');
    return _readObjectList(
      body,
      'attempts',
    ).map(_attemptSummaryFromJson).toList(growable: false);
  }

  @override
  Future<ExamAttemptDetail?> getExamAttempt(String attemptId) async {
    final response = await withApiTimeout(
      _client.get(
        _endpoint('learning/attempts/${Uri.encodeComponent(attemptId)}'),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    if (response.statusCode == 404) {
      return null;
    }
    final body = _decodeResponse(response, 'getExamAttempt');
    return _attemptDetailFromJson(_readObject(body, 'attempt'));
  }

  Uri _endpoint(String path) => _baseUri.resolve(path);

  Map<String, dynamic> _decodeResponse(
    http.Response response,
    String operation,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AttemptApiException(
        '$operation failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    try {
      return _asObject(jsonDecode(response.body), 'response body');
    } on FormatException catch (error) {
      throw AttemptApiException(
        '$operation returned malformed JSON: ${error.message}',
        statusCode: response.statusCode,
      );
    }
  }

  static Uri _parseBaseUrl(String baseUrl) {
    final normalized = baseUrl.trim();
    final uri = Uri.tryParse(normalized);
    if (normalized.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Must be an absolute URL.');
    }
    return Uri.parse(normalized.endsWith('/') ? normalized : '$normalized/');
  }
}

class AttemptApiException implements Exception {
  const AttemptApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

ExamAttemptSummary _attemptSummaryFromJson(Map<String, dynamic> json) {
  return ExamAttemptSummary(
    id: _readString(json, 'id'),
    questionSetId: _readString(json, 'questionSetId'),
    questionSetTitle: _readString(json, 'questionSetTitle'),
    startedAt: _readNullableDate(json, 'startedAt'),
    completedAt: _readDate(json, 'completedAt'),
    totalQuestions: _readInt(json, 'totalQuestions'),
    correctAnswers: _readInt(json, 'correctAnswers'),
    wrongAnswers: _readInt(json, 'wrongAnswers'),
    unansweredAnswers: _readInt(json, 'unansweredAnswers'),
    percentageScore: _readDouble(json, 'percentageScore'),
  );
}

ExamAttemptDetail _attemptDetailFromJson(Map<String, dynamic> json) {
  final summary = _attemptSummaryFromJson(json);
  return ExamAttemptDetail(
    id: summary.id,
    questionSetId: summary.questionSetId,
    questionSetTitle: summary.questionSetTitle,
    startedAt: summary.startedAt,
    completedAt: summary.completedAt,
    totalQuestions: summary.totalQuestions,
    correctAnswers: summary.correctAnswers,
    wrongAnswers: summary.wrongAnswers,
    unansweredAnswers: summary.unansweredAnswers,
    percentageScore: summary.percentageScore,
    result: quizResultFromJson(_readObject(json, 'result')),
  );
}

Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) =>
    _asObject(json[key], key);

Map<String, dynamic> _asObject(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Expected $field to be an object.');
  }
  return value;
}

List<Map<String, dynamic>> _readObjectList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected $key to be a list.');
  }
  return value.map((item) => _asObject(item, key)).toList(growable: false);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Expected $key to be a string.');
  }
  return value;
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('Expected $key to be nullable text.');
  }
  return value;
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Expected $key to be an integer.');
  }
  return value;
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('Expected $key to be a number.');
  }
  return value.toDouble();
}

DateTime _readDate(Map<String, dynamic> json, String key) {
  final value = _readString(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected $key to be a date.');
  }
  return parsed;
}

DateTime? _readNullableDate(Map<String, dynamic> json, String key) {
  final value = _readNullableString(json, key);
  if (value == null) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected $key to be a date.');
  }
  return parsed;
}
