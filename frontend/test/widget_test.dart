import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/features/learning/models/answer_check_result.dart';
import 'package:frontend/features/learning/models/answer_review.dart';
import 'package:frontend/features/learning/models/question.dart';
import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/learning/models/quiz_result.dart';
import 'package:frontend/features/learning/repositories/learning_repository.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/screens/quiz_result_screen.dart';

void main() {
  testWidgets('opens the StudyHub app', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyHubApp());

    expect(find.text('StudyHub'), findsWidgets);
    expect(find.text('Start learning'), findsOneWidget);
  });

  testWidgets('browses subjects and question sets to open a quiz', (
    WidgetTester tester,
  ) async {
    await _openJavaScriptBasicsQuiz(tester);

    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('JavaScript Basics Check'), findsOneWidget);
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
    await _selectAnswer(tester, '===');
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
      const MaterialApp(home: QuizResultScreen(result: result)),
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
    await tester.pumpWidget(StudyHubApp(learningRepository: repository));

    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JavaScript Basics'));
    await tester.pumpAndSettle();

    expect(find.text('Question sets could not be loaded.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('JavaScript Basics Check'), findsOneWidget);
    expect(repository.questionSetLoadCount, 2);
  });

  testWidgets('retries loading quiz questions after an error', (
    WidgetTester tester,
  ) async {
    final repository = _RetryQuestionRepository();
    await _openJavaScriptBasicsQuiz(tester, learningRepository: repository);

    expect(find.text('Questions could not be loaded.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(repository.questionLoadCount, 2);
  });
}

Future<void> _openJavaScriptBasicsQuiz(
  WidgetTester tester, {
  LearningRepository learningRepository = const MockLearningRepository(),
  String startButtonText = 'Start Exam Mode',
}) async {
  await tester.pumpWidget(StudyHubApp(learningRepository: learningRepository));

  await tester.tap(find.text('Start learning'));
  await tester.pumpAndSettle();
  expect(find.text('Choose a subject'), findsOneWidget);

  await tester.tap(find.text('JavaScript Basics'));
  await tester.pumpAndSettle();
  expect(find.text('JavaScript Basics Check'), findsOneWidget);

  await tester.tap(find.text('JavaScript Basics Check'));
  await tester.pumpAndSettle();
  expect(find.text('About this question set'), findsOneWidget);

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
  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId) {
    questionSetLoadCount++;

    if (questionSetLoadCount == 1) {
      return Future.error(Exception('Temporary question set error'));
    }

    return super.getQuestionSetsBySubjectId(subjectId);
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
