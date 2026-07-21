import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_request.dart';
import '../models/answer_check_result.dart';
import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/paginated_result.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'learning_repository.dart';
import 'learning_result_json_mapper.dart';
import 'media_asset_json_mapper.dart';
import '../../materials/models/study_material.dart';

class ApiLearningRepository implements LearningRepository {
  ApiLearningRepository({
    required String baseUrl,
    http.Client? client,
    this.requestTimeout = defaultApiRequestTimeout,
  }) : _baseUri = _parseBaseUrl(baseUrl),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<List<Subject>> getSubjects() async {
    final body = await _get('learning/subjects');
    return _readObjectList(
      body,
      'subjects',
    ).map(_subjectFromJson).toList(growable: false);
  }

  @override
  Future<List<Topic>> getTopicsBySubjectId(String subjectId) async {
    final body = await _get(
      'learning/subjects/${Uri.encodeComponent(subjectId)}/topics',
    );
    return _readObjectList(
      body,
      'topics',
    ).map(_topicFromJson).toList(growable: false);
  }

  @override
  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId) async {
    final body = await _get(
      'learning/subjects/${Uri.encodeComponent(subjectId)}/question-sets',
    );
    return _readObjectList(
      body,
      'questionSets',
    ).map(_questionSetFromJson).toList(growable: false);
  }

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) async {
    final normalizedQuery = q?.trim();
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'subjectId': ?subjectId,
      'topicId': ?topicId,
      'cursor': ?cursor,
    };
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      queryParameters['q'] = normalizedQuery;
    }
    final uri = _endpoint(
      'learning/question-sets',
    ).replace(queryParameters: queryParameters);
    final response = await withApiTimeout(_client.get(uri), requestTimeout);
    final body = _decodeResponse(response, 'listQuestionSets');
    final parsedNextCursor = _readNullableString(body, 'nextCursor');

    return PaginatedResult(
      items: _readObjectList(
        body,
        'items',
      ).map(_questionSetFromJson).toList(growable: false),
      nextCursor: parsedNextCursor == null || parsedNextCursor.isEmpty
          ? null
          : parsedNextCursor,
      hasMore: _readBool(body, 'hasMore'),
    );
  }

  @override
  Future<QuestionSet?> getQuestionSetById(String id) async {
    final body = await _get(
      'learning/question-sets/${Uri.encodeComponent(id)}',
    );
    return _questionSetFromJson(_readObject(body, 'questionSet'));
  }

  @override
  Future<PaginatedResult<StudyMaterial>> listStudyMaterials({
    String? subjectId,
    String? topicId,
    String? q,
    StudyMaterialType? materialType,
    String? language,
    int limit = 20,
    String? cursor,
  }) async {
    final normalizedQuery = q?.trim();
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'subjectId': ?subjectId,
      'topicId': ?topicId,
      'materialType': ?materialType?.name,
      'language': ?language,
      'cursor': ?cursor,
    };
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      queryParameters['q'] = normalizedQuery;
    }
    final response = await withApiTimeout(
      _client.get(
        _endpoint(
          'learning/materials',
        ).replace(queryParameters: queryParameters),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response, 'listStudyMaterials');
    final nextCursor = _readNullableString(body, 'nextCursor');
    return PaginatedResult(
      items: _readObjectList(
        body,
        'items',
      ).map(_studyMaterialFromJson).toList(growable: false),
      nextCursor: nextCursor == null || nextCursor.isEmpty ? null : nextCursor,
      hasMore: _readBool(body, 'hasMore'),
    );
  }

  @override
  Future<StudyMaterial?> getStudyMaterialById(String id) async {
    final body = await _get('learning/materials/${Uri.encodeComponent(id)}');
    return _studyMaterialFromJson(_readObject(body, 'material'));
  }

  @override
  Future<List<Question>> getQuestionsByQuestionSetId(String id) async {
    final body = await _get(
      'learning/question-sets/${Uri.encodeComponent(id)}/questions',
    );
    return _readObjectList(body, 'questions')
        .map((json) => _questionFromJson(json, baseUri: _baseUri))
        .toList(growable: false);
  }

  @override
  Future<AnswerCheckResult> checkAnswer({
    required String questionId,
    required String selectedAnswerOptionId,
  }) async {
    final response = await withApiTimeout(
      _client.post(
        _endpoint(
          'learning/questions/${Uri.encodeComponent(questionId)}/check-answer',
        ),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'selectedAnswerOptionId': selectedAnswerOptionId}),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response, 'checkAnswer');
    return _answerCheckResultFromJson(
      _readObject(body, 'result'),
      baseUri: _baseUri,
    );
  }

  @override
  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  }) async {
    final response = await withApiTimeout(
      _client.post(
        _endpoint(
          'learning/question-sets/${Uri.encodeComponent(questionSetId)}/submit',
        ),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'selectedAnswerOptionIdsByQuestionId':
              selectedAnswerOptionIdsByQuestionId,
        }),
      ),
      requestTimeout,
    );
    final body = _decodeResponse(response, 'submitQuiz');
    return quizResultFromJson(
      _readObject(body, 'result'),
      mediaBaseUri: _baseUri,
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await withApiTimeout(
      _client.get(_endpoint(path)),
      requestTimeout,
    );
    return _decodeResponse(response, 'GET /$path');
  }

  Uri _endpoint(String path) => _baseUri.resolve(path);

  Map<String, dynamic> _decodeResponse(
    http.Response response,
    String operation,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LearningApiException(
        '$operation failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      return _asObject(decoded, 'response body');
    } on FormatException catch (error) {
      throw LearningApiException(
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

class LearningApiException implements Exception {
  const LearningApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'LearningApiException: $message';
}

Subject _subjectFromJson(Map<String, dynamic> json) {
  return Subject(
    id: _readString(json, 'id'),
    name: _readString(json, 'name'),
    school: _readNullableString(json, 'school'),
    program: _readNullableString(json, 'program'),
    major: _readNullableString(json, 'major'),
    description: _readNullableString(json, 'description'),
  );
}

Topic _topicFromJson(Map<String, dynamic> json) {
  return Topic(
    id: _readString(json, 'id'),
    subjectId: _readString(json, 'subjectId'),
    name: _readString(json, 'name'),
  );
}

QuestionSet _questionSetFromJson(Map<String, dynamic> json) {
  return QuestionSet(
    id: _readString(json, 'id'),
    subjectId: _readString(json, 'subjectId'),
    topicId: _readNullableString(json, 'topicId'),
    title: _readString(json, 'title'),
    description: _readString(json, 'description'),
    questionCount: _readInt(json, 'questionCount'),
    estimatedMinutes: _readOptionalInt(json, 'estimatedMinutes'),
    difficulty: _readNullableString(json, 'difficulty'),
    createdAt: _readOptionalDateTime(json, 'createdAt'),
  );
}

Question _questionFromJson(Map<String, dynamic> json, {Uri? baseUri}) {
  return Question(
    id: _readString(json, 'id'),
    questionSetId: _readString(json, 'questionSetId'),
    text: _readString(json, 'text'),
    media: mediaAssetFromJson(json['media'], baseUri: baseUri),
    answerOptions: _readObjectList(
      json,
      'answerOptions',
    ).map(_answerOptionFromJson).toList(growable: false),
  );
}

AnswerOption _answerOptionFromJson(Map<String, dynamic> json) {
  return AnswerOption(
    id: _readString(json, 'id'),
    text: _readString(json, 'text'),
  );
}

AnswerCheckResult _answerCheckResultFromJson(
  Map<String, dynamic> json, {
  Uri? baseUri,
}) {
  return AnswerCheckResult(
    questionId: _readString(json, 'questionId'),
    selectedAnswerOptionId: _readString(json, 'selectedAnswerOptionId'),
    selectedAnswerText: _readString(json, 'selectedAnswerText'),
    correctAnswerOptionId: _readString(json, 'correctAnswerOptionId'),
    correctAnswerText: _readString(json, 'correctAnswerText'),
    isCorrect: _readBool(json, 'isCorrect'),
    explanation: _readNullableString(json, 'explanation'),
    questionMedia: mediaAssetFromJson(json['questionMedia'], baseUri: baseUri),
    explanationMedia: mediaAssetFromJson(
      json['explanationMedia'],
      baseUri: baseUri,
    ),
  );
}

StudyMaterial _studyMaterialFromJson(Map<String, dynamic> json) {
  final createdAt = _readOptionalDateTime(json, 'createdAt');
  if (createdAt == null) {
    throw const FormatException('Expected "createdAt" to be a date string.');
  }
  return StudyMaterial(
    id: _readString(json, 'id'),
    subjectId: _readString(json, 'subjectId'),
    topicId: _readNullableString(json, 'topicId'),
    title: _readString(json, 'title'),
    description: _readString(json, 'description'),
    materialType: _studyMaterialTypeFromJson(_readString(json, 'materialType')),
    language: _readNullableString(json, 'language'),
    createdAt: createdAt,
    sourceType: _studyMaterialSourceTypeFromJson(
      _readNullableString(json, 'sourceType'),
    ),
    sourceUrl: _readNullableString(json, 'sourceUrl'),
    fileName: _readNullableString(json, 'fileName'),
    mimeType: _readNullableString(json, 'mimeType'),
    fileSizeBytes: _readOptionalInt(json, 'fileSizeBytes'),
    updatedAt: _readOptionalDateTime(json, 'updatedAt'),
  );
}

StudyMaterialType _studyMaterialTypeFromJson(String value) {
  return StudyMaterialType.values.firstWhere(
    (type) => type.name == value,
    orElse: () =>
        throw FormatException('Unknown study material type "$value".'),
  );
}

StudyMaterialSourceType? _studyMaterialSourceTypeFromJson(String? value) {
  if (value == null) {
    return null;
  }
  return StudyMaterialSourceType.values.firstWhere(
    (type) => type.name == value,
    orElse: () =>
        throw FormatException('Unknown study material source type "$value".'),
  );
}

List<Map<String, dynamic>> _readObjectList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected "$key" to be a list.');
  }

  return value
      .map((item) => _asObject(item, 'item in "$key"'))
      .toList(growable: false);
}

Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) {
  return _asObject(json[key], '"$key"');
}

Map<String, dynamic> _asObject(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Expected $field to be an object.');
  }
  return value;
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Expected "$key" to be a string.');
  }
  return value;
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('Expected "$key" to be a string or null.');
  }
  return value;
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Expected "$key" to be an integer.');
  }
  return value;
}

int? _readOptionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! int) {
    throw FormatException('Expected "$key" to be an integer or null.');
  }
  return value;
}

DateTime? _readOptionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('Expected "$key" to be a date string or null.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected "$key" to contain a valid date.');
  }
  return parsed;
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('Expected "$key" to be a boolean.');
  }
  return value;
}
