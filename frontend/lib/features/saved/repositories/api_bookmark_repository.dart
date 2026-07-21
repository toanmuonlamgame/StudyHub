import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/access_token_provider.dart';
import '../../../core/api_request.dart';
import '../../learning/models/question_set.dart';
import 'bookmark_repository.dart';

class ApiBookmarkRepository extends BookmarkRepository {
  ApiBookmarkRepository({
    required String baseUrl,
    required this.accessTokenProvider,
    http.Client? client,
    this.requestTimeout = defaultApiRequestTimeout,
  }) : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final AccessTokenProvider accessTokenProvider;
  final Duration requestTimeout;

  @override
  Future<List<QuestionSet>> listBookmarks() async {
    final response = await withApiTimeout(
      _client.get(
        _baseUri.resolve('learning/bookmarks'),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    final json = _decode(response);
    final items = json['items'];
    if (items is! List) throw const FormatException('Expected bookmark items.');
    return items
        .map((item) => _questionSet(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> save(QuestionSet questionSet) async {
    final response = await withApiTimeout(
      _client.put(
        _baseUri.resolve(
          'learning/bookmarks/${Uri.encodeComponent(questionSet.id)}',
        ),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    _decode(response);
    notifyListeners();
  }

  @override
  Future<void> remove(String questionSetId) async {
    final response = await withApiTimeout(
      _client.delete(
        _baseUri.resolve(
          'learning/bookmarks/${Uri.encodeComponent(questionSetId)}',
        ),
        headers: await authenticatedJsonHeaders(accessTokenProvider),
      ),
      requestTimeout,
    );
    if (response.statusCode != 204) _decode(response);
    notifyListeners();
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Bookmark request failed with status ${response.statusCode}.',
      );
    }
    if (response.statusCode == 204) return const {};
    final value = jsonDecode(response.body);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected response object.');
    }
    return value;
  }

  static QuestionSet _questionSet(Map<String, dynamic> json) => QuestionSet(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    topicId: json['topicId'] as String?,
    title: json['title'] as String,
    description: json['description'] as String,
    questionCount: json['questionCount'] as int,
    estimatedMinutes: json['estimatedMinutes'] as int?,
    difficulty: json['difficulty'] as String?,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}
