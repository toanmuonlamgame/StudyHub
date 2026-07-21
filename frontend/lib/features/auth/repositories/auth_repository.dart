import '../models/auth_session.dart';
import '../models/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<AuthSession> login({required String email, required String password});
  Future<AuthUser> getCurrentUser(String accessToken);
  Future<AuthUser> updateDisplayName(String accessToken, String displayName);
  Future<void> logout(String accessToken);
}

class AuthRequestException implements Exception {
  const AuthRequestException(this.message, {this.code, this.field});
  final String message;
  final String? code;
  final String? field;
}
