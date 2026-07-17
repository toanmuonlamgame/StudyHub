import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/learning/models/quiz_result.dart';
import 'package:frontend/features/learning/repositories/learning_repository.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/screens/quiz_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/features/attempts/attempt_repository_scope.dart';
import 'package:frontend/features/attempts/models/exam_attempt.dart';
import 'package:frontend/features/attempts/repositories/attempt_repository.dart';

const _questionSet = QuestionSet(
  id: 'question_set_js_basics',
  subjectId: 'subject_javascript',
  topicId: 'topic_js_syntax',
  title: 'JavaScript Basics Check',
  description: 'Review variables, equality, and arrays.',
  questionCount: 3,
);

void main() {
  testWidgets('keeps changed answers across previous and next navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpExam(tester);

    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.text('0 answered · 3 unanswered'), findsOneWidget);
    expect(find.text('Previous'), findsNothing);

    await _selectAnswer(tester, 'const');
    await _selectAnswer(tester, 'let');
    await tester.fling(find.byType(ListView), const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();
    expect(find.text('1 answered · 2 unanswered'), findsOneWidget);

    await _tapVisible(tester, 'Next Question');
    await _scrollExamToTop(tester);
    expect(find.text('Question 2 of 3'), findsOneWidget);
    await _tapVisible(tester, 'Next Question');
    await _scrollExamToTop(tester);
    expect(find.text('Question 3 of 3'), findsOneWidget);
    expect(find.text('Next Question'), findsNothing);
    final submitButton = find.text('Submit Quiz');
    await tester.scrollUntilVisible(submitButton, 220);
    expect(submitButton, findsOneWidget);

    await _tapVisible(tester, 'Previous');
    await _tapVisible(tester, 'Previous');
    final answerGroup = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(answerGroup.groupValue, 'js_b1_c');
    expect(tester.takeException(), isNull);
  });

  testWidgets('submits unanswered questions with clear confirmation and review', (
    tester,
  ) async {
    await _pumpExam(tester);
    await _selectAnswer(tester, 'let');
    await _tapVisible(tester, 'Next Question');
    await _tapVisible(tester, 'Next Question');

    await _tapVisible(tester, 'Submit Quiz');
    expect(find.text('Submit exam?'), findsOneWidget);
    expect(
      find.text('2 unanswered question(s) remain. Submit anyway?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Submit anyway'));
    await tester.pumpAndSettle();

    expect(find.text('33%'), findsOneWidget);
    expect(find.text('Unanswered'), findsWidgets);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Your answer: Not answered'), findsNWidgets(2));
    expect(find.text('Explanation'), findsNWidgets(2));
    expect(
      find.text(
        '`let` declares a block-scoped variable whose value may be reassigned.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('guards duplicate submission while scoring is pending', (
    tester,
  ) async {
    final repository = _DelayedSubmitRepository();
    await _pumpExam(tester, repository: repository);

    await _selectAnswer(tester, 'let');
    await _tapVisible(tester, 'Next Question');
    await _selectAnswer(tester, '===');
    await _tapVisible(tester, 'Next Question');
    await _selectAnswer(tester, 'push');

    final submitButton = find.text('Submit Quiz');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(repository.submitCount, 1);
    expect(find.text('Submit exam?'), findsNothing);

    await repository.complete();
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('successful exam result triggers attempt persistence once', (
    tester,
  ) async {
    final attemptRepository = _RecordingAttemptRepository();
    await tester.pumpWidget(
      AttemptRepositoryScope(
        repository: attemptRepository,
        child: _localizedApp(
          const QuizScreen(
            questionSet: _questionSet,
            learningRepository: MockLearningRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _selectAnswer(tester, 'let');
    await _tapVisible(tester, 'Next Question');
    await _selectAnswer(tester, '===');
    await _tapVisible(tester, 'Next Question');
    await _selectAnswer(tester, 'push');
    await _tapVisible(tester, 'Submit Quiz');
    await tester.pumpAndSettle();

    expect(attemptRepository.saveCalls, 1);
    expect(attemptRepository.lastRequest?.selectedAnswerOptionIdsByQuestionId, {
      'question_js_basics_1': 'js_b1_c',
      'question_js_basics_2': 'js_b2_b',
      'question_js_basics_3': 'js_b3_c',
    });
    expect(find.text('Result saved'), findsOneWidget);
  });

  testWidgets('asks before leaving progress but not an untouched exam', (
    tester,
  ) async {
    await _pumpLauncher(tester);
    await tester.tap(find.text('Open exam'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Open exam'), findsOneWidget);
    expect(find.text('Leave exam?'), findsNothing);

    await tester.tap(find.text('Open exam'));
    await tester.pumpAndSettle();
    await _selectAnswer(tester, 'let');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Leave exam?'), findsOneWidget);
    expect(
      find.text('Your selected answers will be discarded.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep learning'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard progress'));
    await tester.pumpAndSettle();
    expect(find.text('Open exam'), findsOneWidget);
  });
}

Future<void> _pumpExam(
  WidgetTester tester, {
  LearningRepository repository = const MockLearningRepository(),
}) async {
  await tester.pumpWidget(
    _localizedApp(
      QuizScreen(questionSet: _questionSet, learningRepository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpLauncher(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuizScreen(
                    questionSet: _questionSet,
                    learningRepository: MockLearningRepository(),
                  ),
                ),
              ),
              child: const Text('Open exam'),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

Future<void> _selectAnswer(WidgetTester tester, String text) async {
  final answer = find.text(text);
  await tester.ensureVisible(answer);
  await tester.pumpAndSettle();
  await tester.tap(answer);
  await tester.pump();
}

Future<void> _tapVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 220);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _scrollExamToTop(WidgetTester tester) async {
  await tester.fling(find.byType(ListView), const Offset(0, 1200), 1200);
  await tester.pumpAndSettle();
}

class _DelayedSubmitRepository extends MockLearningRepository {
  final Completer<QuizResult> _completer = Completer<QuizResult>();
  int submitCount = 0;
  String? _questionSetId;
  Map<String, String>? _selectedAnswerIds;

  @override
  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  }) {
    submitCount++;
    _questionSetId = questionSetId;
    _selectedAnswerIds = selectedAnswerOptionIdsByQuestionId;
    return _completer.future;
  }

  Future<void> complete() async {
    final result = await super.submitQuiz(
      questionSetId: _questionSetId!,
      selectedAnswerOptionIdsByQuestionId: _selectedAnswerIds!,
    );
    _completer.complete(result);
  }
}

class _RecordingAttemptRepository extends AttemptRepository {
  int saveCalls = 0;
  ExamAttemptSaveRequest? lastRequest;

  @override
  Future<ExamAttemptDetail> saveExamAttempt(
    ExamAttemptSaveRequest request,
  ) async {
    saveCalls++;
    lastRequest = request;
    final result = await const MockLearningRepository().submitQuiz(
      questionSetId: request.questionSetId,
      selectedAnswerOptionIdsByQuestionId:
          request.selectedAnswerOptionIdsByQuestionId,
    );
    return ExamAttemptDetail(
      id: 'attempt_1',
      questionSetId: result.questionSetId,
      questionSetTitle: result.questionSetTitle,
      startedAt: request.startedAt,
      completedAt: DateTime.utc(2026, 7, 17),
      totalQuestions: result.totalCount,
      correctAnswers: result.correctCount,
      wrongAnswers: result.wrongCount,
      unansweredAnswers: result.unansweredCount,
      percentageScore: result.percentageScore,
      result: result,
    );
  }

  @override
  Future<ExamAttemptDetail?> getExamAttempt(String attemptId) async => null;

  @override
  Future<List<ExamAttemptSummary>> listExamAttempts() async => const [];
}
