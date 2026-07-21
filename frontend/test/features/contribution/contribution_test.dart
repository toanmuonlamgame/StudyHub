import 'dart:async';
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
import 'package:frontend/features/contribution/models/contribution_submission.dart';
import 'package:frontend/features/contribution/models/submission_confirmation.dart';
import 'package:frontend/features/contribution/repositories/api_contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/mock_contribution_repository.dart';
import 'package:frontend/features/contribution/screens/contribution_editor_screen.dart';
import 'package:frontend/features/contribution/screens/contribution_intro_screen.dart';
import 'package:frontend/features/contribution/screens/paste_exam_screen.dart';
import 'package:frontend/features/contribution/screens/submission_confirmation_screen.dart';
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
      final repository = MockContributionRepository();
      final confirmation = await repository.submitForReview(
        _validDraft(),
        submissionId: 'test-submission-1',
      );
      expect(confirmation.status, 'pendingReview');

      await expectLater(
        repository.submitForReview(
          const QuestionSetDraft(),
          submissionId: 'test-submission-2',
        ),
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

      final result = await repository.submitForReview(
        _validDraft(),
        submissionId: 'test-submission-3',
      );
      expect(result.status, 'pendingReview');
      expect(requestBody.containsKey('createdByUserId'), isFalse);
      expect(requestBody['submissionId'], 'test-submission-3');
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
      repository.submitForReview(
        _validDraft(),
        submissionId: 'test-submission-4',
      ),
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
      repository.submitForReview(
        _validDraft(),
        submissionId: 'test-submission-5',
      ),
      throwsA(isA<ContributionSubmissionException>()),
    );
  });

  test(
    'API contribution times out without losing the submitted draft',
    () async {
      final draft = _validDraft();
      final repository = ApiContributionRepository(
        baseUrl: 'http://localhost:3000',
        client: MockClient((_) => Completer<http.Response>().future),
        requestTimeout: const Duration(milliseconds: 1),
      );

      await expectLater(
        repository.submitForReview(
          draft,
          submissionId: 'test-submission-timeout',
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(draft.title, 'Community set');
      expect(draft.questions, hasLength(1));
    },
  );

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
    expect(find.text('Create exam quickly'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Paste full exam'),
      200,
      scrollable: _contributionIntroScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paste full exam'), findsOneWidget);
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
          home: ContributionEditorScreen(
            learningRepository: const MockLearningRepository(),
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

    await tester.tap(find.text('Review and finish'));
    await tester.pumpAndSettle();
    expect(find.text('Review Submission'), findsOneWidget);
    expect(find.text('Correct Answer'), findsOneWidget);

    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();

    expect(find.text('Pending Review'), findsOneWidget);
    expect(find.text('Community set'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('submission-back-to-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-hub-list')), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    expect(find.text('Pending Review'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Pending Review'), findsNothing);
  });

  testWidgets('submission failure preserves the creator draft', (tester) async {
    final repository = _FailingContributionRepository();
    await tester.pumpWidget(
      StudyHubApp(
        contributionRepository: repository,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );
    await _openContributionEditor(tester);
    await _fillValidContribution(tester);
    await tester.tap(find.text('Review and finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();

    expect(find.text('Community set'), findsOneWidget);
    expect(find.textContaining('Your draft is still here'), findsOneWidget);

    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    final retryButton = find.text('Submit for Review');
    await tester.ensureVisible(retryButton);
    await tester.pumpAndSettle();
    await tester.tap(retryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();
    expect(repository.submissionIds, hasLength(2));
    expect(repository.submissionIds.toSet(), hasLength(1));
  });

  testWidgets('submission success remains usable on a short scaled phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: SubmissionConfirmationScreen(
            confirmation: SubmissionConfirmation(
              id: 'submission-compact',
              status: 'pendingReview',
              title: 'Bộ câu hỏi cộng đồng có tiêu đề dài để kiểm tra bố cục',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('submission-back-to-home')),
      findsOneWidget,
    );
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

  testWidgets(
    'manual creator can duplicate a question without leaving editor',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ContributionEditorScreen(
            learningRepository: const MockLearningRepository(),
            contributionRepository: MockContributionRepository(),
            initialDraft: _validDraft(),
            startWithQuestions: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Duplicate question'));
      await tester.pump();

      expect(find.text('2 questions'), findsOneWidget);
    },
  );

  testWidgets('paste exam previews valid questions before importing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const PasteExamScreen(baseDraft: QuestionSetDraft()),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('paste-exam-input')),
      '/question: 2 + 2?\n/answer1: 3\n/answer2: 4\n/correct: 2\n/explanation: Basic addition.',
    );
    final previewAction = find.text('Check and preview');
    await tester.ensureVisible(previewAction);
    await tester.pumpAndSettle();
    await tester.tap(previewAction);
    await tester.pumpAndSettle();

    expect(find.text('1 recognized'), findsOneWidget);
    expect(find.text('1 valid'), findsOneWidget);
    expect(find.text('0 invalid'), findsOneWidget);
    expect(find.text('2. 4'), findsOneWidget);
    expect(find.text('Basic addition.'), findsOneWidget);
    final importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Edit recognized questions'),
    );
    expect(importButton.onPressed, isNotNull);
  });

  testWidgets('pasted exam submission returns directly to Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    final tile = find.byKey(const ValueKey('contribution-home-tile'));
    await tester.scrollUntilVisible(tile, 300, scrollable: _homeScrollable());
    await tester.drag(_homeScrollable(), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    final pasteAction = find.text('Paste full exam');
    await tester.scrollUntilVisible(
      pasteAction,
      200,
      scrollable: _contributionIntroScrollable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(pasteAction);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('paste-exam-input')),
      '/question: 2 + 2?\n/answer1: 3\n/answer2: 4\n/correct: 2',
    );
    final previewAction = find.text('Check and preview');
    await tester.ensureVisible(previewAction);
    await tester.pumpAndSettle();
    await tester.tap(previewAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit recognized questions'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('JavaScript Basics').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Pasted set',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review and finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pumpAndSettle();

    expect(find.text('Pending Review'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('submission-back-to-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-hub-list')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Pending Review'), findsNothing);
  });

  testWidgets('paste exam blocks import while severe errors remain', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const PasteExamScreen(baseDraft: QuestionSetDraft()),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('paste-exam-input')),
      '/question: Broken\n/answer1: One\n/correct: 4',
    );
    await tester.tap(find.text('Check and preview'));
    await tester.pumpAndSettle();

    expect(find.text('1 invalid'), findsOneWidget);
    final importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Edit recognized questions'),
    );
    expect(importButton.onPressed, isNull);
    final fixButton = find.text('Fix this question in the source');
    await tester.ensureVisible(fixButton);
    await tester.pumpAndSettle();
    await tester.tap(fixButton);
    await tester.pumpAndSettle();
    final input = tester.widget<TextField>(
      find.byKey(const Key('paste-exam-input')),
    );
    expect(input.focusNode?.hasFocus, isTrue);
  });

  testWidgets('paste exam remains usable with keyboard on a compact phone', (
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
          home: const PasteExamScreen(baseDraft: QuestionSetDraft()),
        ),
      ),
    );

    final input = find.byKey(const Key('paste-exam-input'));
    await tester.showKeyboard(input);
    await tester.enterText(input, '/question: Compact');
    await tester.scrollUntilVisible(
      find.text('Check and preview'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump();

    expect(find.text('Check and preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending submission disables repeat submission', (tester) async {
    final repository = _DelayedContributionRepository();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ContributionEditorScreen(
          learningRepository: const MockLearningRepository(),
          contributionRepository: repository,
          initialDraft: _validDraft(),
          startWithQuestions: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review and finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit for Review').last);
    await tester.pump();

    expect(repository.calls, 1);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is FilledButton && widget.onPressed == null,
      ),
      findsWidgets,
    );

    repository.complete();
    await tester.pumpAndSettle();
    expect(find.text('Pending Review'), findsOneWidget);
  });
}

Finder _homeScrollable() => find
    .descendant(
      of: find.byKey(const ValueKey('home-hub-list')),
      matching: find.byType(Scrollable),
    )
    .first;

Finder _contributionIntroScrollable() => find
    .descendant(
      of: find.byType(ContributionIntroScreen),
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
  final createAction = find.text('Create exam quickly');
  await tester.ensureVisible(createAction);
  await tester.pumpAndSettle();
  await tester.tap(createAction);
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
  await tester.tap(find.text('Continue'));
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

class _FailingContributionRepository
    with _UnsupportedContributionManagement
    implements ContributionRepository {
  final List<String> submissionIds = [];

  @override
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  }) {
    submissionIds.add(submissionId);
    throw const ContributionSubmissionException('Network unavailable.');
  }
}

class _DelayedContributionRepository
    with _UnsupportedContributionManagement
    implements ContributionRepository {
  final _completer = Completer<SubmissionConfirmation>();
  int calls = 0;

  @override
  Future<SubmissionConfirmation> submitForReview(
    QuestionSetDraft draft, {
    required String submissionId,
  }) {
    calls++;
    return _completer.future;
  }

  void complete() {
    _completer.complete(
      const SubmissionConfirmation(
        id: 'submission-delayed',
        status: 'pendingReview',
        title: 'Community set',
      ),
    );
  }
}

mixin _UnsupportedContributionManagement {
  Future<List<ContributionSubmission>> listSubmissions() =>
      throw UnimplementedError();
  Future<ContributionSubmission> createDraft(QuestionSetDraft draft) =>
      throw UnimplementedError();
  Future<ContributionSubmission> updateDraft(
    String submissionId,
    QuestionSetDraft draft,
  ) => throw UnimplementedError();
  Future<void> deleteDraft(String submissionId) => throw UnimplementedError();
  Future<SubmissionConfirmation> submitDraftForReview(String submissionId) =>
      throw UnimplementedError();
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
