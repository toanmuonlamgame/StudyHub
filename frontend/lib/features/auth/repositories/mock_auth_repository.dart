import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final Map<String, ({AuthUser user, String password})> _users = {};
  final Map<String, AuthUser> _sessions = {};
  int _nextId = 1;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (_users.containsKey(normalized)) {
      throw const AuthRequestException(
        'Account already exists.',
        code: 'ACCOUNT_EXISTS',
      );
    }
    final user = AuthUser(
      id: 'mock-user-${_nextId++}',
      email: normalized,
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );
    _users[normalized] = (user: user, password: password);
    return _createSession(user);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final record = _users[email.trim().toLowerCase()];
    if (record == null || record.password != password) {
      throw const AuthRequestException(
        'Invalid credentials.',
        code: 'INVALID_CREDENTIALS',
      );
    }
    return _createSession(record.user);
  }

  @override
  Future<AuthUser> getCurrentUser(String accessToken) async {
    final user = _sessions[accessToken];
    if (user == null) {
      throw const AuthRequestException(
        'Session expired.',
        code: 'AUTHENTICATION_REQUIRED',
      );
    }
    return user;
  }

  @override
  Future<void> logout(String accessToken) async =>
      _sessions.remove(accessToken);

  @override
  Future<AuthUser> updateDisplayName(
    String accessToken,
    String displayName,
  ) async {
    final current = await getCurrentUser(accessToken);
    final updated = current.copyWith(displayName: displayName.trim());
    _sessions[accessToken] = updated;
    _users[current.email] = (
      user: updated,
      password: _users[current.email]!.password,
    );
    return updated;
  }

  AuthSession _createSession(AuthUser user) {
    final token = 'mock-session-${DateTime.now().microsecondsSinceEpoch}';
    _sessions[token] = user;
    return AuthSession(
      user: user,
      accessToken: token,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }
}
