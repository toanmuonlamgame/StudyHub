import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/learning/models/quiz_mode.dart';
import 'package:frontend/features/learning/models/quiz_result.dart';
import 'package:frontend/features/learning/screens/quiz_result_screen.dart';
import 'package:frontend/features/progress/models/completed_learning_session.dart';
import 'package:frontend/features/progress/progress_store_scope.dart';
import 'package:frontend/features/progress/repositories/progress_store.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  testWidgets('Exam result saves trusted progress exactly once', (
    tester,
  ) async {
    final store = _MemoryProgressStore();
    await tester.pumpWidget(
      _localizedResult(
        store: store,
        result: _result(quizMode: QuizMode.exam),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();

    expect(store.saveCallCount, 1);
    expect(store.sessions.single.quizMode, QuizMode.exam);
    expect(store.sessions.single.correctCount, 2);
  });

  testWidgets('Practice result saves trusted progress exactly once', (
    tester,
  ) async {
    final store = _MemoryProgressStore();
    await tester.pumpWidget(
      _localizedResult(
        store: store,
        result: _result(quizMode: QuizMode.practice),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();

    expect(store.saveCallCount, 1);
    expect(store.sessions.single.quizMode, QuizMode.practice);
  });

  testWidgets('local save failure does not block the result screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedResult(
        store: _FailingProgressStore(),
        result: _result(quizMode: QuizMode.exam),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exam Result'), findsOneWidget);
    expect(
      find.textContaining('local progress could not be saved'),
      findsOneWidget,
    );
  });

  testWidgets('Progress shows an honest empty state', (tester) async {
    await tester.pumpWidget(
      StudyHubApp(
        progressStore: _MemoryProgressStore(),
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    await _openProgress(tester, 'Progress');

    expect(find.text('No progress yet'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
  });

  testWidgets('Progress calculates metrics from completed sessions', (
    tester,
  ) async {
    final store = _MemoryProgressStore([
      _session(
        id: 'practice',
        questionSetId: 'set-2',
        title: 'Database Review',
        mode: QuizMode.practice,
        percentage: 50,
        completedAt: DateTime(2026, 7, 14, 9),
      ),
      _session(
        id: 'exam',
        questionSetId: 'set-1',
        title: 'JavaScript Basics Check',
        mode: QuizMode.exam,
        percentage: 100,
        completedAt: DateTime(2026, 7, 13, 9),
      ),
    ]);
    await tester.pumpWidget(
      StudyHubApp(
        progressStore: store,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    await _openProgress(tester, 'Progress');

    expect(find.byKey(const ValueKey('progress-history')), findsOneWidget);
    expect(find.text('Completed sessions'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Database Review'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('JavaScript Basics Check'),
      250,
      scrollable: _progressScrollable(),
    );
    expect(find.text('JavaScript Basics Check'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
  });

  testWidgets('clear history requires confirmation', (tester) async {
    final store = _MemoryProgressStore([
      _session(
        id: 'exam',
        questionSetId: 'set-1',
        title: 'JavaScript Basics Check',
        mode: QuizMode.exam,
        percentage: 100,
        completedAt: DateTime(2026, 7, 14),
      ),
    ]);
    await tester.pumpWidget(
      StudyHubApp(
        progressStore: store,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    await _openProgress(tester, 'Progress');

    await tester.tap(find.byTooltip('Clear history'));
    await tester.pumpAndSettle();
    expect(find.text('Clear local history?'), findsOneWidget);
    expect(store.clearCallCount, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();
    expect(store.clearCallCount, 1);
    expect(find.text('No progress yet'), findsOneWidget);
  });

  testWidgets('Progress supports Vietnamese interface copy', (tester) async {
    final store = _MemoryProgressStore([
      _session(
        id: 'practice',
        questionSetId: 'set-1',
        title: 'JavaScript Basics Check',
        mode: QuizMode.practice,
        percentage: 50,
        completedAt: DateTime(2026, 7, 14),
      ),
    ]);
    await tester.pumpWidget(
      StudyHubApp(
        progressStore: store,
        initialLocaleSelection: AppLocaleSelection.vietnamese,
      ),
    );
    await _openProgress(tester, 'Tiến độ');

    expect(find.text('Phiên đã hoàn thành'), findsOneWidget);
    expect(find.text('Kết quả gần đây'), findsOneWidget);
    expect(find.text('Luyện tập'), findsOneWidget);
  });

  testWidgets('Progress fits compact width with larger text', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      StudyHubApp(
        progressStore: _MemoryProgressStore([
          _session(
            id: 'practice',
            questionSetId: 'set-1',
            title: 'JavaScript Basics Check With A Longer Creator Title',
            mode: QuizMode.practice,
            percentage: 66.666,
            completedAt: DateTime(2026, 7, 14),
          ),
        ]),
        initialLocaleSelection: AppLocaleSelection.vietnamese,
      ),
    );
    await _openProgress(tester, 'Tiến độ');

    expect(tester.takeException(), isNull);
  });
}

Widget _localizedResult({
  required ProgressStore store,
  required QuizResult result,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: ProgressStoreScope(
      progressStore: store,
      child: QuizResultScreen(result: result),
    ),
  );
}

Future<void> _openProgress(WidgetTester tester, String label) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Finder _progressScrollable() {
  return find
      .descendant(
        of: find.byKey(const ValueKey('progress-list')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .first;
}

QuizResult _result({required QuizMode quizMode}) {
  return QuizResult(
    questionSetId: 'set-1',
    questionSetTitle: 'JavaScript Basics Check',
    correctCount: 2,
    wrongCount: 1,
    totalCount: 3,
    percentageScore: 66.666,
    answerReviews: const [],
    quizMode: quizMode,
  );
}

CompletedLearningSession _session({
  required String id,
  required String questionSetId,
  required String title,
  required QuizMode mode,
  required double percentage,
  required DateTime completedAt,
}) {
  return CompletedLearningSession(
    id: id,
    questionSetId: questionSetId,
    questionSetTitle: title,
    quizMode: mode,
    correctCount: percentage == 100 ? 2 : 1,
    totalQuestions: 2,
    percentage: percentage,
    completedAt: completedAt,
  );
}

class _MemoryProgressStore extends ProgressStore {
  _MemoryProgressStore([List<CompletedLearningSession> initial = const []])
    : sessions = List.of(initial);

  final List<CompletedLearningSession> sessions;
  int saveCallCount = 0;
  int clearCallCount = 0;

  @override
  Future<List<CompletedLearningSession>> loadSessions() async {
    final result = List<CompletedLearningSession>.of(sessions);
    result.sort((left, right) => right.completedAt.compareTo(left.completedAt));
    return result;
  }

  @override
  Future<void> saveCompletedSession(CompletedLearningSession session) async {
    saveCallCount++;
    sessions.removeWhere((item) => item.id == session.id);
    sessions.add(session);
    notifyListeners();
  }

  @override
  Future<void> clearHistory() async {
    clearCallCount++;
    sessions.clear();
    notifyListeners();
  }
}

class _FailingProgressStore extends ProgressStore {
  @override
  Future<List<CompletedLearningSession>> loadSessions() async => const [];

  @override
  Future<void> saveCompletedSession(CompletedLearningSession session) {
    throw StateError('Local storage unavailable.');
  }

  @override
  Future<void> clearHistory() async {}
}
