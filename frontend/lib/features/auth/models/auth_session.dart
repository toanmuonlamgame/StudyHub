import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
  });

  final AuthUser user;
  final String accessToken;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  Map<String, Object> toJson() => {
    'user': user.toJson(),
    'accessToken': accessToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  static AuthSession fromJson(Map<String, dynamic> json) => AuthSession(
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    accessToken: json['accessToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}
