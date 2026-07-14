import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/learning/models/answer_check_result.dart';
import 'package:frontend/features/learning/models/answer_review.dart';
import 'package:frontend/features/learning/models/question.dart';
import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/learning/models/paginated_result.dart';
import 'package:frontend/features/learning/models/quiz_result.dart';
import 'package:frontend/features/learning/models/subject.dart';
import 'package:frontend/features/learning/repositories/learning_repository.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/screens/quiz_result_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('supports English and Vietnamese interface locales', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll(const [Locale('en'), Locale('vi')]),
    );
  });

  testWidgets('opens the StudyHub app', (WidgetTester tester) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    expect(find.text('StudyHub'), findsWidgets);
    expect(find.text('Featured'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-carousel')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-indicator')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-quick-action-grid')),
      300,
      scrollable: _homeScrollable(),
    );
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.textContaining('discount'), findsNothing);
    expect(find.textContaining('% off'), findsNothing);
  });

  testWidgets('switches between honest top-level app sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    expect(_navigationLabel('Home'), findsOneWidget);
    expect(_navigationLabel('Learn'), findsOneWidget);
    expect(_navigationLabel('Progress'), findsOneWidget);
    expect(_navigationLabel('Settings'), findsOneWidget);

    await tester.tap(_navigationLabel('Learn'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a subject'), findsOneWidget);

    await tester.tap(_navigationLabel('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Your learning overview'), findsOneWidget);
    expect(find.text('No progress yet'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.text('0'), findsNothing);

    await tester.tap(_navigationLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('About StudyHub'), findsOneWidget);
    expect(find.text('Learning safety'), findsWidgets);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('featured banner is manually swipeable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    expect(find.bySemanticsLabel('Featured item 1 of 3'), findsWidgets);
    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Featured item 2 of 3'), findsWidgets);
  });

  testWidgets('home shortcuts switch tabs without eager subject loading', (
    WidgetTester tester,
  ) async {
    final repository = _SubjectLoadTrackingRepository();
    await tester.pumpWidget(
      StudyHubApp(
        learningRepository: repository,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    expect(repository.subjectLoadCount, 0);

    await _tapHomeShortcut(tester, 'progress');
    expect(find.text('Your learning overview'), findsOneWidget);
    expect(repository.subjectLoadCount, 0);

    await tester.tap(_navigationLabel('Home'));
    await tester.pumpAndSettle();
    await _tapHomeShortcut(tester, 'settings');
    expect(find.text('Language'), findsOneWidget);
    expect(repository.subjectLoadCount, 0);

    await tester.tap(_navigationLabel('Home'));
    await tester.pumpAndSettle();
    await _startLearningFromHome(tester);
    expect(find.text('Choose a subject'), findsOneWidget);
    expect(repository.subjectLoadCount, 1);
  });

  testWidgets('Home labels active and upcoming destinations honestly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await tester.scrollUntilVisible(
      find.text('Study Materials'),
      350,
      scrollable: _homeScrollable(),
    );
    expect(find.text('Coming soon'), findsWidgets);
    expect(find.bySemanticsLabel('Study Materials'), findsOneWidget);
    expect(find.bySemanticsLabel('Study Materials, coming soon'), findsNothing);
  });

  testWidgets('progress call to action switches to Learn', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await tester.tap(_navigationLabel('Progress'));
    await tester.pumpAndSettle();
    final progressCta = find.byKey(const ValueKey('progress-start-learning'));
    await tester.scrollUntilVisible(
      progressCta,
      200,
      scrollable: _verticalScrollableWithin('progress-list'),
    );
    await tester.ensureVisible(progressCta);
    await tester.pumpAndSettle();
    await tester.tap(progressCta);
    await tester.pumpAndSettle();

    expect(find.text('Choose a subject'), findsOneWidget);
  });

  testWidgets('deep learning route returns to subject list cleanly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await _startLearningFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('JavaScript Basics'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Choose a subject'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('top-level learner UI fits a compact phone surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(_navigationLabel('Learn'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a subject'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches to Vietnamese and keeps learning content unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await tester.tap(_navigationLabel('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Học tập'), findsOneWidget);
    expect(find.text('Cài đặt'), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(_navigationLabel('Trang chủ'));
    await tester.pumpAndSettle();
    await _startLearningFromHome(tester);
    await tester.pumpAndSettle();
    expect(find.text('Chọn môn học'), findsOneWidget);
    expect(find.text('JavaScript Basics'), findsOneWidget);
  });

  testWidgets('Vietnamese shell supports compact phone and larger text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.vietnamese),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nổi bật'), findsOneWidget);
    expect(find.text('Học tập'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('persists the selected interface language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await tester.tap(_navigationLabel('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const StudyHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Học tập'), findsOneWidget);
    expect(_navigationLabel('Cài đặt'), findsOneWidget);
  });

  testWidgets('browses subjects and question sets to open a quiz', (
    WidgetTester tester,
  ) async {
    await _openJavaScriptBasicsQuiz(tester);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Exam Mode'), findsOneWidget);
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(
      find.text(
        'Which keyword declares a block-scoped variable that can change?',
      ),
      findsOneWidget,
    );
  });

  testWidgets('submits a quiz and shows score with answer review', (
    WidgetTester tester,
  ) async {
    final repository = _TrackingSubmitRepository();
    await _openJavaScriptBasicsQuiz(tester, learningRepository: repository);

    await _selectAnswer(tester, 'const');
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();
    await _selectAnswer(tester, '===');
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();
    await _selectAnswer(tester, 'push');

    final submitButton = find.text('Submit Quiz');
    await tester.scrollUntilVisible(submitButton, 250);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.submitCount, 1);
    expect(repository.submittedAnswerIds, hasLength(3));
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Correct answers'), findsOneWidget);

    final answerReview = find.text('Answer review');
    await tester.scrollUntilVisible(answerReview, 250);

    expect(answerReview, findsOneWidget);
    expect(find.text('Your answer: const'), findsOneWidget);
    expect(find.text('Correct answer: let'), findsOneWidget);
    expect(find.text('Incorrect'), findsOneWidget);

    final secondQuestion = find.text(
      'Which operator checks value and type equality?',
    );
    await tester.scrollUntilVisible(secondQuestion, 250);

    expect(find.text('Correct'), findsWidgets);
  });

  testWidgets('practice mode checks an answer before showing feedback', (
    WidgetTester tester,
  ) async {
    final repository = _TrackingCheckAnswerRepository();
    await _openJavaScriptBasicsQuiz(
      tester,
      learningRepository: repository,
      startButtonText: 'Start Practice Mode',
    );

    expect(find.text('Practice Mode'), findsOneWidget);
    expect(find.text('Incorrect'), findsNothing);

    await _selectAnswer(tester, 'const');
    await tester.pumpAndSettle();

    expect(repository.checkCount, 1);
    expect(find.text('Incorrect'), findsOneWidget);
    expect(find.text('Your answer: const'), findsOneWidget);
    expect(find.text('Correct answer: let'), findsOneWidget);

    final nextQuestionButton = find.text('Next Question');
    await tester.scrollUntilVisible(nextQuestionButton, 200);
    expect(nextQuestionButton, findsOneWidget);
  });

  testWidgets('practice mode finishes with trusted result and review', (
    WidgetTester tester,
  ) async {
    final repository = _TrackingCheckAnswerRepository();
    await _openJavaScriptBasicsQuiz(
      tester,
      learningRepository: repository,
      startButtonText: 'Start Practice Mode',
    );

    await _selectAnswer(tester, 'const');
    await tester.pumpAndSettle();
    final firstNextButton = find.text('Next Question');
    await tester.scrollUntilVisible(firstNextButton, 200);
    await tester.tap(firstNextButton);
    await tester.pumpAndSettle();

    await _selectAnswer(tester, '===');
    await tester.pumpAndSettle();
    final secondNextButton = find.text('Next Question');
    await tester.scrollUntilVisible(secondNextButton, 200);
    await tester.tap(secondNextButton);
    await tester.pumpAndSettle();

    await _selectAnswer(tester, 'push');
    await tester.pumpAndSettle();
    final finishButton = find.text('Finish Practice');
    await tester.scrollUntilVisible(finishButton, 200);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(repository.checkCount, 3);
    expect(find.text('Practice Result'), findsOneWidget);
    expect(find.text('Practice Mode'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Correct answers'), findsOneWidget);
    expect(find.text('Answer review'), findsOneWidget);
    expect(find.text('Your answer: const'), findsOneWidget);
    expect(find.text('Correct answer: let'), findsOneWidget);
  });

  testWidgets('renders answer review directly from QuizResult', (
    WidgetTester tester,
  ) async {
    const result = QuizResult(
      questionSetId: 'result_only_set',
      questionSetTitle: 'Result-only Question Set',
      correctCount: 0,
      wrongCount: 1,
      totalCount: 1,
      percentageScore: 0,
      answerReviews: [
        AnswerReview(
          questionId: 'result_only_question',
          questionText: 'Review supplied by QuizResult',
          selectedAnswerOptionId: 'selected_option',
          selectedAnswerText: 'Selected from result',
          correctAnswerOptionId: 'correct_option',
          correctAnswerText: 'Correct from result',
          isCorrect: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const QuizResultScreen(result: result),
      ),
    );

    expect(find.text('Result-only Question Set'), findsOneWidget);
    expect(find.text('Review supplied by QuizResult'), findsOneWidget);
    expect(find.text('Your answer: Selected from result'), findsOneWidget);
    expect(find.text('Correct answer: Correct from result'), findsOneWidget);
    expect(find.text('Incorrect'), findsOneWidget);
  });

  testWidgets('retries loading question sets after an error', (
    WidgetTester tester,
  ) async {
    final repository = _RetryQuestionSetRepository();
    await tester.pumpWidget(
      StudyHubApp(
        learningRepository: repository,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );

    await _startLearningFromHome(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('JavaScript Basics'));
    await tester.pumpAndSettle();

    expect(find.text('Question sets could not be loaded'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('JavaScript Basics Check'), findsOneWidget);
    expect(repository.questionSetLoadCount, 2);
  });

  testWidgets('Vietnamese result fits compact screen with larger text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    const result = QuizResult(
      questionSetId: 'compact_result',
      questionSetTitle: 'Nội dung học giữ nguyên',
      correctCount: 2,
      wrongCount: 1,
      totalCount: 3,
      percentageScore: 66.67,
      answerReviews: [
        AnswerReview(
          questionId: 'compact_question',
          questionText: 'Creator content is not translated',
          selectedAnswerOptionId: 'selected',
          selectedAnswerText: 'Selected content',
          correctAnswerOptionId: 'correct',
          correctAnswerText: 'Correct content',
          isCorrect: false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const QuizResultScreen(result: result),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kết quả kiểm tra'), findsOneWidget);
    expect(find.text('Nội dung học giữ nguyên'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retries loading quiz questions after an error', (
    WidgetTester tester,
  ) async {
    final repository = _RetryQuestionRepository();
    await _openJavaScriptBasicsQuiz(tester, learningRepository: repository);

    expect(find.text('Questions could not be loaded'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(repository.questionLoadCount, 2);
  });
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}

Future<void> _tapHomeShortcut(WidgetTester tester, String id) async {
  final shortcut = find.byKey(ValueKey('home-quick-$id'));
  await tester.fling(_homeScrollable(), const Offset(0, 1200), 1200);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(shortcut, 250, scrollable: _homeScrollable());
  await tester.ensureVisible(shortcut);
  await tester.pumpAndSettle();
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

Finder _homeScrollable() {
  return _verticalScrollableWithin('home-hub-list');
}

Finder _verticalScrollableWithin(String key) {
  return find
      .descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .first;
}

Future<void> _startLearningFromHome(WidgetTester tester) {
  return _tapHomeShortcut(tester, 'start-learning');
}

Future<void> _openJavaScriptBasicsQuiz(
  WidgetTester tester, {
  LearningRepository learningRepository = const MockLearningRepository(),
  String startButtonText = 'Start Exam Mode',
}) async {
  await tester.pumpWidget(
    StudyHubApp(
      learningRepository: learningRepository,
      initialLocaleSelection: AppLocaleSelection.english,
    ),
  );

  await _startLearningFromHome(tester);
  await tester.pumpAndSettle();
  expect(find.text('Choose a subject'), findsOneWidget);

  await tester.tap(find.text('JavaScript Basics'));
  await tester.pumpAndSettle();
  expect(find.text('JavaScript Basics Check'), findsOneWidget);

  await tester.tap(find.text('JavaScript Basics Check'));
  await tester.pumpAndSettle();
  expect(find.text('About this question set'), findsOneWidget);

  final chooseModeButton = find.text('Choose learning mode');
  await tester.ensureVisible(chooseModeButton);
  await tester.tap(chooseModeButton);
  await tester.pumpAndSettle();
  expect(find.text('How do you want to learn?'), findsOneWidget);

  final startQuizButton = find.text(startButtonText);
  await tester.ensureVisible(startQuizButton);
  await tester.tap(startQuizButton);
  await tester.pumpAndSettle();
}

Future<void> _selectAnswer(WidgetTester tester, String answer) async {
  final answerFinder = find.text(answer);
  await tester.scrollUntilVisible(answerFinder, 250);
  await tester.tap(answerFinder);
  await tester.pump();
}

class _RetryQuestionSetRepository extends MockLearningRepository {
  int questionSetLoadCount = 0;

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) {
    questionSetLoadCount++;

    if (questionSetLoadCount == 1) {
      return Future.error(Exception('Temporary question set error'));
    }

    return super.listQuestionSets(
      subjectId: subjectId,
      topicId: topicId,
      q: q,
      limit: limit,
      cursor: cursor,
    );
  }
}

class _SubjectLoadTrackingRepository extends MockLearningRepository {
  int subjectLoadCount = 0;

  @override
  Future<List<Subject>> getSubjects() {
    subjectLoadCount++;
    return super.getSubjects();
  }
}

class _RetryQuestionRepository extends MockLearningRepository {
  int questionLoadCount = 0;

  @override
  Future<List<Question>> getQuestionsByQuestionSetId(String id) {
    questionLoadCount++;

    if (questionLoadCount == 1) {
      return Future.error(Exception('Temporary question error'));
    }

    return super.getQuestionsByQuestionSetId(id);
  }
}

class _TrackingSubmitRepository extends MockLearningRepository {
  int submitCount = 0;
  Map<String, String> submittedAnswerIds = const {};

  @override
  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  }) {
    submitCount++;
    submittedAnswerIds = selectedAnswerOptionIdsByQuestionId;

    return super.submitQuiz(
      questionSetId: questionSetId,
      selectedAnswerOptionIdsByQuestionId: selectedAnswerOptionIdsByQuestionId,
    );
  }
}

class _TrackingCheckAnswerRepository extends MockLearningRepository {
  int checkCount = 0;

  @override
  Future<AnswerCheckResult> checkAnswer({
    required String questionId,
    required String selectedAnswerOptionId,
  }) {
    checkCount++;

    return super.checkAnswer(
      questionId: questionId,
      selectedAnswerOptionId: selectedAnswerOptionId,
    );
  }
}
