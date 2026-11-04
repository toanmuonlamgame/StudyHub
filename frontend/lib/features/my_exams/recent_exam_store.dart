import 'package:shared_preferences/shared_preferences.dart';

import '../auth/models/auth_user.dart';

class RecentExamStore {
  RecentExamStore(this._account, {this.guestSession});

  final AuthUser? _account;
  static const limit = 8;
  static final _guest = Expando<List<String>>();
  final Object? guestSession;

  String get _key {
    final account = _account!;
    return 'studyhub.recent_exams.${account.id}.${account.createdAt.toUtc().millisecondsSinceEpoch}';
  }

  Future<List<String>> load() async {
    if (_account == null) {
      final session = guestSession;
      return session == null ? [] : [...?_guest[session]];
    }
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet().take(limit).toList();
  }

  Future<void> record(String id) async {
    if (id.isEmpty || id.length > 128) return;
    if (_account == null) {
      final session = guestSession;
      if (session != null) {
        _guest[session] = _prepend(id, _guest[session] ?? []);
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _prepend(id, prefs.getStringList(_key) ?? []),
    );
  }

  Future<void> clear() async {
    if (_account == null) {
      final session = guestSession;
      if (session != null) _guest[session] = null;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(_key)) throw StateError('Could not clear history.');
  }

  List<String> _prepend(String id, List<String> previous) =>
      {id, ...previous}.take(limit).toList();
}
