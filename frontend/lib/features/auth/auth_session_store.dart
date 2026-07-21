import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/auth_session.dart';

class AuthSessionStore {
  const AuthSessionStore();
  static const _key = 'studyhub.auth.session.v1';

  Future<AuthSession?> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final session = AuthSession.fromJson(json);
      return session.isExpired ? null : session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<String?> loadAccessToken() async => (await load())?.accessToken;

  Future<void> save(AuthSession session) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(session.toJson()),
    );
  }

  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}
