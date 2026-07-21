// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import 'auth_session_store.dart';
import 'models/auth_session.dart';
import 'models/auth_user.dart';
import 'repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required AuthSessionStore store,
  }) : _repository = repository,
       _store = store;

  final AuthRepository _repository;
  final AuthSessionStore _store;
  AuthSession? _session;
  bool _loading = true;
  String? _errorCode;

  bool get loading => _loading;
  bool get isAuthenticated => _session != null;
  AuthUser? get user => _session?.user;
  String? get errorCode => _errorCode;

  Future<void> restore() async {
    _loading = true;
    notifyListeners();
    final stored = await _store.load();
    if (stored == null) {
      _session = null;
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      final user = await _repository.getCurrentUser(stored.accessToken);
      _session = AuthSession(
        user: user,
        accessToken: stored.accessToken,
        expiresAt: stored.expiresAt,
      );
      await _store.save(_session!);
    } catch (_) {
      _session = null;
      await _store.clear();
      _errorCode = 'AUTHENTICATION_REQUIRED';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) =>
      _runSessionRequest(
        () => _repository.login(email: email, password: password),
      );

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) => _runSessionRequest(
    () => _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  Future<bool> updateDisplayName(String displayName) async {
    final session = _session;
    if (session == null) return false;
    _errorCode = null;
    try {
      final user = await _repository.updateDisplayName(
        session.accessToken,
        displayName,
      );
      _session = AuthSession(
        user: user,
        accessToken: session.accessToken,
        expiresAt: session.expiresAt,
      );
      await _store.save(_session!);
      notifyListeners();
      return true;
    } on AuthRequestException catch (error) {
      _errorCode = error.code ?? 'REQUEST_FAILED';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final token = _session?.accessToken;
    _session = null;
    _errorCode = null;
    await _store.clear();
    notifyListeners();
    if (token != null) {
      try {
        await _repository.logout(token);
      } catch (_) {
        // Local logout must succeed even when the backend is unavailable.
      }
    }
  }

  Future<bool> _runSessionRequest(
    Future<AuthSession> Function() request,
  ) async {
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _session = await request();
      await _store.save(_session!);
      _loading = false;
      notifyListeners();
      return true;
    } on AuthRequestException catch (error) {
      _loading = false;
      _errorCode = error.code ?? 'REQUEST_FAILED';
      notifyListeners();
      return false;
    } catch (_) {
      _loading = false;
      _errorCode = 'REQUEST_FAILED';
      notifyListeners();
      return false;
    }
  }
}
