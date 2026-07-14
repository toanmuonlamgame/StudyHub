import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/completed_learning_session.dart';
import 'progress_store.dart';

class SharedPreferencesProgressStore extends ProgressStore {
  static const storageKey = 'studyhub.completed_learning_sessions.v1';
  static const historyLimit = 100;

  @override
  Future<List<CompletedLearningSession>> loadSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return const [];
      }

      final sessions = <CompletedLearningSession>[];
      for (final value in decoded) {
        if (value is! Map) {
          continue;
        }
        try {
          sessions.add(
            CompletedLearningSession.fromJson(
              value.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        } on FormatException {
          continue;
        }
      }
      sessions.sort(_newestFirst);
      return List.unmodifiable(sessions.take(historyLimit));
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<void> saveCompletedSession(CompletedLearningSession session) async {
    final sessions = (await loadSessions()).toList();
    final existingIndex = sessions.indexWhere((item) => item.id == session.id);
    if (existingIndex >= 0) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }
    sessions.sort(_newestFirst);
    final boundedSessions = sessions.take(historyLimit).toList();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      jsonEncode(boundedSessions.map((item) => item.toJson()).toList()),
    );
    notifyListeners();
  }

  @override
  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
    notifyListeners();
  }

  static int _newestFirst(
    CompletedLearningSession left,
    CompletedLearningSession right,
  ) {
    final dateComparison = right.completedAt.compareTo(left.completedAt);
    return dateComparison != 0 ? dateComparison : right.id.compareTo(left.id);
  }
}
