import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/features/learning/models/quiz_mode.dart';
import 'package:frontend/features/progress/models/completed_learning_session.dart';
import 'package:frontend/features/progress/repositories/shared_preferences_progress_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('completed session serializes and deserializes trusted result data', () {
    final session = _session(
      id: 'session-1',
      completedAt: DateTime.utc(2026, 7, 14, 10, 30),
      quizMode: QuizMode.practice,
    );

    expect(CompletedLearningSession.fromJson(session.toJson()), session);
  });

  test('malformed local storage falls back to an empty history', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProgressStore.storageKey: '{not-json',
    });
    final store = SharedPreferencesProgressStore();

    expect(await store.loadSessions(), isEmpty);
  });

  test('save and load return newest sessions first', () async {
    final store = SharedPreferencesProgressStore();
    await store.saveCompletedSession(
      _session(id: 'older', completedAt: DateTime.utc(2026, 7, 13)),
    );
    await store.saveCompletedSession(
      _session(id: 'newer', completedAt: DateTime.utc(2026, 7, 14)),
    );

    expect((await store.loadSessions()).map((session) => session.id), [
      'newer',
      'older',
    ]);
  });

  test('history is bounded to the latest one hundred sessions', () async {
    final store = SharedPreferencesProgressStore();
    for (var index = 0; index < 105; index++) {
      await store.saveCompletedSession(
        _session(
          id: 'session-$index',
          completedAt: DateTime.utc(2026, 1, 1).add(Duration(days: index)),
        ),
      );
    }

    final sessions = await store.loadSessions();
    expect(sessions, hasLength(100));
    expect(sessions.first.id, 'session-104');
    expect(sessions.last.id, 'session-5');
  });

  test('saving the same session id twice does not duplicate history', () async {
    final store = SharedPreferencesProgressStore();
    final session = _session(
      id: 'same-session',
      completedAt: DateTime.utc(2026, 7, 14),
    );

    await store.saveCompletedSession(session);
    await store.saveCompletedSession(session);

    expect(await store.loadSessions(), [session]);
  });
}

CompletedLearningSession _session({
  required String id,
  required DateTime completedAt,
  QuizMode quizMode = QuizMode.exam,
}) {
  return CompletedLearningSession(
    id: id,
    questionSetId: 'set-1',
    questionSetTitle: 'JavaScript Basics Check',
    quizMode: quizMode,
    correctCount: 2,
    totalQuestions: 3,
    percentage: 66.6666666667,
    completedAt: completedAt,
  );
}
