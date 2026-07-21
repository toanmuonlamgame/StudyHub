import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_request.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required String baseUrl,
    http.Client? client,
    this.requestTimeout = defaultApiRequestTimeout,
  }) : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  }) => _sessionRequest('auth/register', {
    'email': email,
    'password': password,
    'displayName': displayName,
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _sessionRequest('auth/login', {'email': email, 'password': password});

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    final response = await withApiTimeout(
      _client.get(
        _baseUri.resolve('auth/me'),
        headers: _authHeaders(accessToken),
      ),
      requestTimeout,
    );
    return _readUser(_decodeSuccess(response));
  }

  @override
  Future<AuthUser> updateDisplayName(
    String accessToken,
    String displayName,
  ) async {
    final response = await withApiTimeout(
      _client.patch(
        _baseUri.resolve('auth/me'),
        headers: _authHeaders(accessToken),
        body: jsonEncode({'displayName': displayName}),
      ),
      requestTimeout,
    );
    return _readUser(_decodeSuccess(response));
  }

  @override
  Future<void> logout(String accessToken) async {
    final response = await withApiTimeout(
      _client.post(
        _baseUri.resolve('auth/logout'),
        headers: _authHeaders(accessToken),
      ),
      requestTimeout,
    );
    if (response.statusCode != 204) _throwResponseError(response);
  }

  Future<AuthSession> _sessionRequest(
    String path,
    Map<String, Object> body,
  ) async {
    final response = await withApiTimeout(
      _client.post(
        _baseUri.resolve(path),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode(body),
      ),
      requestTimeout,
    );
    final json = _decodeSuccess(response);
    final token = json['accessToken'];
    final expiresAt = json['expiresAt'];
    if (token is! String || expiresAt is! String) {
      throw const AuthRequestException('Malformed authentication response.');
    }
    return AuthSession(
      user: _readUser(json),
      accessToken: token,
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  Map<String, dynamic> _decodeSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwResponseError(response);
    }
    return _decodeObject(response.body);
  }

  Never _throwResponseError(http.Response response) {
    final body = _decodeObject(response.body, allowMalformed: true);
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      throw AuthRequestException(
        error['message'] as String? ?? 'Authentication request failed.',
        code: error['code'] as String?,
        field: error['field'] as String?,
      );
    }
    throw AuthRequestException(
      'Authentication failed with status ${response.statusCode}.',
    );
  }

  static AuthUser _readUser(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthRequestException('Malformed user response.');
    }
    try {
      return AuthUser.fromJson(user);
    } catch (_) {
      throw const AuthRequestException('Malformed user response.');
    }
  }

  static Map<String, dynamic> _decodeObject(
    String body, {
    bool allowMalformed = false,
  }) {
    try {
      final value = jsonDecode(body);
      if (value is Map<String, dynamic>) return value;
    } catch (_) {
      // Converted to a stable repository error below.
    }
    if (allowMalformed) return const {};
    throw const AuthRequestException('Malformed server response.');
  }

  static Map<String, String> _authHeaders(String token) => {
    'content-type': 'application/json',
    'authorization': 'Bearer $token',
  };
}
