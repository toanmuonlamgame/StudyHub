import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/contribution/models/answer_option_draft.dart';
import 'package:frontend/features/contribution/models/question_draft.dart';
import 'package:frontend/features/contribution/models/question_set_draft.dart';
import 'package:frontend/features/contribution/models/submission_confirmation.dart';
import 'package:frontend/features/contribution/repositories/api_contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/mock_contribution_repository.dart';
import 'package:frontend/features/contribution/screens/contribution_editor_screen.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('creator draft validates one correct and unique answers', () {
    final draft = _validDraft().copyWith(
      questions: [
        QuestionDraft(
          id: 'q1',
          text: 'Question?',
          answerOptions: const [
            AnswerOptionDraft(id: 'a1', text: 'Same', isCorrect: true),
            AnswerOptionDraft(id: 'a2', text: ' same ', isCorrect: true),
          ],
        ),
      ],
    );

    final issues = draft.validateForSubmission();
    expect(issues.any((issue) => issue.message.contains('unique')), isTrue);
    expect(
      issues.any((issue) => issue.message.contains('exactly one')),
      isTrue,
    );
  });

  test('creator draft enforces bounded question and answer counts', () {
    final tooManyQuestions = _validDraft().copyWith(
      questions: List.filled(
        contributionQuestionCountMax + 1,
        _validDraft().questions.first,
      ),
    );
    final tooManyAnswers = _validDraft().copyWith(
      questions: [
        _validDraft().questions.first.copyWith(
          answerOptions: List.generate(
            contributionAnswerOptionCountMax + 1,
            (index) => AnswerOptionDraft(
              id: 'a$index',
              text: 'Answer $index',
              isCorrect: index == 0,
            ),
          ),
        ),
      ],
    );

    expect(
      tooManyQuestions.validateForSubmission().any(
        (issue) => issue.path == 'questions',
      ),
      isTrue,
    );
    expect(
      tooManyAnswers.validateForSubmission().any(
        (issue) => issue.path == 'questions[0].answerOptions',
      ),
      isTrue,
    );
  });

  test(
    'mock contribution returns pendingReview and rejects incomplete data',
    () async {
      const repository = MockContributionRepository();
      final confirmation = await repository.submitForReview(_validDraft());
      expect(confirmation.status, 'pendingReview');

      await expectLater(
        repository.submitForReview(const QuestionSetDraft()),
        throwsA(isA<ContributionValidationException>()),
      );
    },
  );

  test(
    'API contribution maps pending confirmation and sends creator DTO',
    () async {
      late Map<String, dynamic> requestBody;
      final repository = ApiContributionRepository(
        baseUrl: 'http://localhost:3000',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/learning/question-set-submissions/submit');
          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'submission': {
                'id': 'submission_1',
                'status': 'pendingReview',
                'title': 'Community set',
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final result = await repository.submitForReview(_validDraft());
      expect(result.status, 'pendingReview');
      expect(requestBody.containsKey('createdByUserId'), isFalse);
      expect(
        ((requestBody['questions'] as List).first as Map)['answerOptions'],
        isA<List>(),
      );
    },
  );

  test('API contribution maps structured validation errors', () async {
    final repository = ApiContributionRepository(
      baseUrl: 'http://localhost:3000',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'SUBMISSION_VALIDATION_FAILED',
              'message': 'Invalid',
              'fields': [
                {'path': 'title', 'message': 'Title is required.'},
              ],
            },
          }),
          400,
        ),
      ),
    );

    await expectLater(
      repository.submitForReview(_validDraft()),
      throwsA(
        isA<ContributionValidationException>().having(
          (error) => error.issues.first.path,
          'field path',
          'title',
        ),
      ),
    );
  });

  test('API contribution rejects a non-pending success response', () async {
    final repository = ApiContributionRepository(
      baseUrl: 'http://localhost:3000',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'submission': {
              'id': 'submission_1',
              'status': 'draft',
              'title': 'Community set',
            },
          }),
          201,
        ),
      ),
    );

    await expectLater(
      repository.submitForReview(_validDraft()),
      throwsA(isA<ContributionSubmissionException>()),
    );
  });

  testWidgets('Home opens localized contribution introduction lazily', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    final contributionTile = find.byKey(
      const ValueKey('contribution-home-tile'),
    );
    await tester.scrollUntilVisible(
      contributionTile,
      300,
      scrollable: _homeScrollable(),
    );
    await tester.ensureVisible(contributionTile);
    await tester.pumpAndSettle();
    await tester.tap(contributionTile);
    await tester.pumpAndSettle();

    expect(find.text('Share a useful question set'), findsOneWidget);
    expect(find.text('Create Question Set'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Vietnamese contribution intro fits a compact scaled viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: const StudyHubApp(
          initialLocaleSelection: AppLocaleSelection.vietnamese,
        ),
      ),
    );
    final contributionTile = find.byKey(
      const ValueKey('contribution-home-tile'),
    );
    await tester.scrollUntilVisible(
      contributionTile,
      300,
      scrollable: _homeScrollable(),
    );
    await tester.ensureVisible(contributionTile);
    await tester.pumpAndSettle();
    await tester.tap(contributionTile);
    await tester.pumpAndSettle();

    expect(find.text('Chia sẻ bộ câu hỏi hữu ích'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creator form remains usable with keyboard on a compact phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ContributionEditorScreen(
            learningRepository: MockLearningRepository(),
            contributionRepository: MockContributionRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final titleField = find.widgetWithText(TextField, 'Title');
    await tester.ensureVisible(titleField);
    await tester.showKeyboard(titleField);
    await tester.enterText(titleField, 'Compact creator draft');
    await tester.pump();

    expect(find.text('Compact creator draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds and submits a question set for pending review', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await _openContributionEditor(tester);
    await _fillValidContribution(tester);

    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();
    expect(find.text('Review Submission'), findsOneWidget);
    expect(find.text('Correct Answer'), findsOneWidget);

    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();

    expect(find.text('Pending Review'), findsOneWidget);
    expect(find.text('Community set'), findsOneWidget);
  });

  testWidgets('submission failure preserves the creator draft', (tester) async {
    await tester.pumpWidget(
      const StudyHubApp(
        contributionRepository: _FailingContributionRepository(),
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    await _openContributionEditor(tester);
    await _fillValidContribution(tester);
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();

    expect(find.text('Community set'), findsOneWidget);
    expect(find.textContaining('Your draft is still here'), findsOneWidget);
  });

  testWidgets('unsaved creator changes require discard confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await _openContributionEditor(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Unsaved set',
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    expect(find.text('Continue Editing'), findsOneWidget);
  });
}

Finder _homeScrollable() => find
    .descendant(
      of: find.byKey(const ValueKey('home-hub-list')),
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _openContributionEditor(WidgetTester tester) async {
  final tile = find.byKey(const ValueKey('contribution-home-tile'));
  await tester.scrollUntilVisible(tile, 300, scrollable: _homeScrollable());
  await tester.drag(_homeScrollable(), const Offset(0, -180));
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Create Question Set'));
  await tester.pumpAndSettle();
}

Future<void> _fillValidContribution(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('JavaScript Basics').last);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextField, 'Title'),
    'Community set',
  );
  await tester.tap(find.text('Next Question'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const ValueKey('question-draft-1-text')),
    'Which declaration is block scoped?',
  );
  await tester.enterText(
    find.byKey(const ValueKey('question-draft-1-answer-draft-1-1')),
    'var',
  );
  await tester.enterText(
    find.byKey(const ValueKey('question-draft-1-answer-draft-1-2')),
    'let',
  );
  final correctRadio = find.byType(Radio<String>).last;
  await tester.ensureVisible(correctRadio);
  await tester.pumpAndSettle();
  await tester.tap(correctRadio);
  await tester.pumpAndSettle();
}

class _FailingContributionRepository implements ContributionRepository {
  const _FailingContributionRepository();

  @override
  Future<SubmissionConfirmation> submitForReview(QuestionSetDraft draft) {
    throw const ContributionSubmissionException('Network unavailable.');
  }
}

QuestionSetDraft _validDraft() => const QuestionSetDraft(
  subjectId: 'subject_javascript',
  topicId: 'topic_js_syntax',
  title: 'Community set',
  description: 'Description',
  questions: [
    QuestionDraft(
      id: 'q1',
      text: 'Which answer is correct?',
      answerOptions: [
        AnswerOptionDraft(id: 'a1', text: 'Wrong'),
        AnswerOptionDraft(id: 'a2', text: 'Correct', isCorrect: true),
      ],
    ),
  ],
);
