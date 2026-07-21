import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/app_navigation.dart';
import 'package:frontend/features/attempts/attempt_repository_scope.dart';
import 'package:frontend/features/attempts/models/exam_attempt.dart';
import 'package:frontend/features/attempts/repositories/attempt_repository.dart';
import 'package:frontend/features/attempts/screens/exam_attempt_history_screen.dart';
import 'package:frontend/features/learning/models/answer_option.dart';
import 'package:frontend/features/learning/models/answer_review.dart';
import 'package:frontend/features/learning/models/quiz_result.dart';
import 'package:frontend/features/learning/screens/quiz_result_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/features/progress/models/completed_learning_session.dart';
import 'package:frontend/features/progress/progress_store_scope.dart';
import 'package:frontend/features/progress/repositories/progress_store.dart';

void main() {
  test('reselecting a navigation tab does not emit duplicate changes', () {
    final controller = AppNavigationController();
    addTearDown(controller.dispose);
    var changes = 0;
    controller.addListener(() => changes++);

    controller.selectTab(2);
    controller.selectTab(2);
    controller.selectTab(0);
    controller.selectTab(0);

    expect(changes, 2);
    expect(controller.selectedTab, 0);
  });

  testWidgets('Exam result shows save loading then saved state exactly once', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository()..holdSave = true;
    await tester.pumpWidget(
      _localized(
        repository,
        QuizResultScreen(result: _result, attemptSaveRequest: _request),
      ),
    );
    await tester.pump();

    expect(find.text('Saving result...'), findsOneWidget);
    expect(repository.saveCalls, 1);
    repository.completeHeldSave();
    await tester.pumpAndSettle();
    expect(find.text('Result saved'), findsOneWidget);
    expect(repository.saveCalls, 1);
  });

  testWidgets('Exam result adopts trusted saved result before local progress', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository(attempt: _attempt)
      ..holdSave = true;
    final progressStore = _CountingProgressStore();
    await tester.pumpWidget(
      _localized(
        repository,
        QuizResultScreen(
          result: _untrustedInitialResult,
          attemptSaveRequest: _request,
        ),
        progressStore: progressStore,
      ),
    );
    await tester.pump();

    expect(find.text('0%'), findsOneWidget);
    expect(progressStore.saveCalls, 0);

    repository.completeHeldSave();
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
    expect(progressStore.saveCalls, 1);
    expect(progressStore.lastSession?.correctCount, 1);
    expect(progressStore.lastSession?.id, 'attempt_1');
  });

  testWidgets('save failure keeps result visible and retries same request', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository()..failNextSave = true;
    await tester.pumpWidget(
      _localized(
        repository,
        QuizResultScreen(result: _result, attemptSaveRequest: _request),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exam Result'), findsOneWidget);
    expect(find.text('Unable to save result'), findsOneWidget);
    await tester.tap(find.text('Retry save'));
    await tester.pumpAndSettle();
    expect(find.text('Result saved'), findsOneWidget);
    expect(repository.saveCalls, 2);
    expect(
      repository.requests[0].submissionId,
      repository.requests[1].submissionId,
    );
  });

  testWidgets('history supports loading and empty states', (tester) async {
    final repository = _FakeAttemptRepository()..holdList = true;
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.completeHeldList(const []);
    await tester.pumpAndSettle();
    expect(find.text('No attempts yet'), findsOneWidget);
  });

  testWidgets('history supports error and retry', (tester) async {
    final repository = _FakeAttemptRepository()..failList = true;
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to load attempt history'), findsOneWidget);
    repository.failList = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No attempts yet'), findsOneWidget);
  });

  testWidgets('history ignores repeated retry taps while loading', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository()..failList = true;
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    repository
      ..failList = false
      ..holdList = true;
    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Try again'), warnIfMissed: false);
    await tester.pump();

    expect(repository.listCalls, 2);
    repository.completeHeldList(const []);
    await tester.pumpAndSettle();
    expect(find.text('No attempts yet'), findsOneWidget);
  });

  testWidgets('history refreshes after a repository change during loading', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository()..holdList = true;
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
      ),
    );
    await tester.pump();

    repository.announceChange();
    repository.completeHeldList(const []);
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.text('No attempts yet'), findsOneWidget);
  });

  testWidgets('history renders score/date and opens reused result review', (
    tester,
  ) async {
    final repository = _FakeAttemptRepository(attempt: _attempt);
    final progressStore = _CountingProgressStore();
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
        progressStore: progressStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Example exam'), findsOneWidget);
    expect(find.text('1 of 1 correct'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('attempt-attempt_1')));
    await tester.pumpAndSettle();
    expect(find.text('Exam Result'), findsOneWidget);
    expect(find.text('Question?'), findsOneWidget);
    expect(find.text('Correct answer: Answer'), findsOneWidget);
    expect(progressStore.saveCalls, 0);
  });

  testWidgets(
    'attempt detail returns directly to Home and clears deep routes',
    (tester) async {
      final repository = _FakeAttemptRepository(attempt: _attempt);
      final navigationController = AppNavigationController()..selectTab(2);
      addTearDown(navigationController.dispose);
      await tester.pumpWidget(
        AppNavigationScope(
          controller: navigationController,
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ExamAttemptDetailScreen(
                          repository: repository,
                          attemptId: _attempt.id,
                        ),
                      ),
                    ),
                    child: const Text('Open attempt detail'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open attempt detail'));
      await tester.pumpAndSettle();
      expect(find.text('Exam Result'), findsOneWidget);

      final homeAction = find.byKey(const ValueKey('result-back-to-home'));
      await tester.scrollUntilVisible(homeAction, 250);
      await tester.tap(homeAction);
      await tester.pumpAndSettle();

      expect(find.text('Open attempt detail'), findsOneWidget);
      expect(find.text('Exam Result'), findsNothing);
      expect(navigationController.selectedTab, 0);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Exam Result'), findsNothing);
    },
  );

  testWidgets('history uses Vietnamese interface strings', (tester) async {
    final repository = _FakeAttemptRepository(attempt: _attempt);
    await tester.pumpWidget(
      _localized(
        repository,
        ExamAttemptHistoryScreen(
          repository: repository,
          onStartLearning: () {},
        ),
        locale: const Locale('vi'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lịch sử làm đề'), findsOneWidget);
    expect(find.text('Đúng 1/1 câu'), findsOneWidget);
    expect(find.textContaining('Đã hoàn thành'), findsOneWidget);
  });
}

Widget _localized(
  AttemptRepository repository,
  Widget child, {
  Locale locale = const Locale('en'),
  ProgressStore? progressStore,
}) {
  final scopedChild = progressStore == null
      ? child
      : ProgressStoreScope(progressStore: progressStore, child: child);
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: AttemptRepositoryScope(repository: repository, child: scopedChild),
  );
}

const _result = QuizResult(
  questionSetId: 'set_1',
  questionSetTitle: 'Example exam',
  correctCount: 1,
  wrongCount: 0,
  totalCount: 1,
  percentageScore: 100,
  answerReviews: [
    AnswerReview(
      questionId: 'q1',
      questionText: 'Question?',
      answerOptions: [AnswerOption(id: 'a1', text: 'Answer')],
      selectedAnswerOptionId: 'a1',
      selectedAnswerText: 'Answer',
      correctAnswerOptionId: 'a1',
      correctAnswerText: 'Answer',
      isCorrect: true,
    ),
  ],
);

const _untrustedInitialResult = QuizResult(
  questionSetId: 'set_1',
  questionSetTitle: 'Example exam',
  correctCount: 0,
  wrongCount: 1,
  totalCount: 1,
  percentageScore: 0,
  answerReviews: [
    AnswerReview(
      questionId: 'q1',
      questionText: 'Question?',
      answerOptions: [AnswerOption(id: 'a1', text: 'Answer')],
      selectedAnswerOptionId: 'a1',
      selectedAnswerText: 'Answer',
      correctAnswerOptionId: 'a2',
      correctAnswerText: 'Different answer',
      isCorrect: false,
    ),
  ],
);

final _request = ExamAttemptSaveRequest(
  submissionId: 'stable-key',
  questionSetId: 'set_1',
  startedAt: DateTime.utc(2026, 7, 17),
  selectedAnswerOptionIdsByQuestionId: const {'q1': 'a1'},
);

final _attempt = ExamAttemptDetail(
  id: 'attempt_1',
  questionSetId: 'set_1',
  questionSetTitle: 'Example exam',
  startedAt: DateTime.utc(2026, 7, 17),
  completedAt: DateTime.utc(2026, 7, 17, 0, 5),
  totalQuestions: 1,
  correctAnswers: 1,
  wrongAnswers: 0,
  unansweredAnswers: 0,
  percentageScore: 100,
  result: _result,
);

class _FakeAttemptRepository extends AttemptRepository {
  _FakeAttemptRepository({this.attempt});

  final ExamAttemptDetail? attempt;
  bool holdSave = false;
  bool failNextSave = false;
  bool holdList = false;
  bool failList = false;
  int saveCalls = 0;
  int listCalls = 0;
  final List<ExamAttemptSaveRequest> requests = [];
  Completer<ExamAttemptDetail>? _saveCompleter;
  Completer<List<ExamAttemptSummary>>? _listCompleter;

  @override
  Future<ExamAttemptDetail> saveExamAttempt(ExamAttemptSaveRequest request) {
    saveCalls++;
    requests.add(request);
    if (failNextSave) {
      failNextSave = false;
      return Future.error(StateError('save failed'));
    }
    if (holdSave) {
      _saveCompleter = Completer<ExamAttemptDetail>();
      return _saveCompleter!.future;
    }
    return Future.value(attempt ?? _attempt);
  }

  void completeHeldSave() {
    holdSave = false;
    _saveCompleter!.complete(attempt ?? _attempt);
  }

  @override
  Future<List<ExamAttemptSummary>> listExamAttempts() {
    listCalls++;
    if (failList) return Future.error(StateError('list failed'));
    if (holdList) {
      _listCompleter = Completer<List<ExamAttemptSummary>>();
      return _listCompleter!.future;
    }
    return Future.value(attempt == null ? const [] : [attempt!]);
  }

  void completeHeldList(List<ExamAttemptSummary> attempts) {
    holdList = false;
    _listCompleter!.complete(attempts);
  }

  void announceChange() => notifyListeners();

  @override
  Future<ExamAttemptDetail?> getExamAttempt(String attemptId) async => attempt;
}

class _CountingProgressStore extends ProgressStore {
  int saveCalls = 0;
  CompletedLearningSession? lastSession;

  @override
  Future<void> clearHistory() async {}

  @override
  Future<List<CompletedLearningSession>> loadSessions() async => const [];

  @override
  Future<void> saveCompletedSession(CompletedLearningSession session) async {
    saveCalls++;
    lastSession = session;
  }
}
