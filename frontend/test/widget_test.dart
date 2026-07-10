import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/studyhub_app.dart';

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
}

Future<void> _openJavaScriptBasicsQuiz(WidgetTester tester) async {
  await tester.pumpWidget(const StudyHubApp());

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
