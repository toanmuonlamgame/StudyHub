import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/features/learning/models/question.dart';
import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/learning/repositories/learning_repository.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';

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
    await _openJavaScriptBasicsQuiz(tester);

    await _selectAnswer(tester, 'const');
    await _selectAnswer(tester, '===');
    await _selectAnswer(tester, 'push');

    final submitButton = find.text('Submit Quiz');
    await tester.scrollUntilVisible(submitButton, 250);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

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

  final startQuizButton = find.text('Start Quiz');
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
