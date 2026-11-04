import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/contribution/repositories/api_contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/contribution_repository.dart';
import 'package:frontend/features/contribution/repositories/mock_contribution_repository.dart';
import 'package:frontend/features/materials/models/study_material.dart';
import 'package:frontend/features/materials/models/study_material_submission.dart';
import 'package:frontend/features/materials/screens/study_material_editor_screen.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('mock material drafts follow the moderation lifecycle', () async {
    final repository = MockContributionRepository();
    final created = await repository.createMaterialDraft(_draft);
    expect(created.status, StudyMaterialSubmissionStatus.draft);
    expect(await repository.listMaterialSubmissions(), hasLength(1));

    final submitted = await repository.submitMaterialDraftForReview(created.id);
    expect(submitted.status, StudyMaterialSubmissionStatus.pendingReview);
    expect(
      () => repository.updateMaterialDraft(created.id, _draft),
      throwsA(isA<ContributionSubmissionException>()),
    );
  });

  test('API material draft uses authenticated backend contract', () async {
    late http.Request captured;
    final repository = ApiContributionRepository(
      baseUrl: 'http://localhost:3000',
      accessTokenProvider: () async => 'session-token',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'submission': {
              'id': 'material-1',
              ..._draft.toJson(),
              'status': 'draft',
              'createdAt': '2026-11-03T12:00:00.000Z',
              'updatedAt': '2026-11-03T12:00:00.000Z',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await repository.createMaterialDraft(
      _draft,
      submissionId: 'material-request-1',
    );
    expect(captured.url.path, '/learning/study-material-submissions');
    expect(captured.headers['authorization'], 'Bearer session-token');
    expect(captured.headers['idempotency-key'], 'material-request-1');
    expect(jsonDecode(captured.body)['sourceType'], 'externalLink');
    expect(result.draft.sourceUrl, _draft.sourceUrl);
  });

  testWidgets('profile opens honest My Study Materials empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('My study materials'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('My study materials'));
    await tester.pumpAndSettle();

    expect(find.text('No shared materials yet'), findsOneWidget);
    expect(find.text('Add material'), findsWidgets);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('retrying submit reuses the draft created by the first attempt', (
    tester,
  ) async {
    final repository = _RetryMaterialRepository();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyMaterialEditorScreen(
          learningRepository: MockLearningRepository(),
          contributionRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      _draft.title,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      _draft.description,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Source link'),
      _draft.sourceUrl,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(find.textContaining('could not be saved'), findsOneWidget);

    await tester.tap(find.text('Submit for Review'));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(repository.submitCalls, 2);
  });
}

const _draft = StudyMaterialDraft(
  subjectId: 'subject_javascript',
  topicId: 'topic_js_syntax',
  title: 'JavaScript reference',
  description: 'A concise external learning reference.',
  materialType: StudyMaterialType.link,
  sourceUrl: 'https://developer.mozilla.org/docs/Web/JavaScript',
  language: 'en',
);

class _RetryMaterialRepository extends MockContributionRepository {
  int createCalls = 0;
  int submitCalls = 0;

  @override
  Future<StudyMaterialSubmission> createMaterialDraft(
    StudyMaterialDraft draft, {
    String? submissionId,
  }) {
    createCalls++;
    return super.createMaterialDraft(draft, submissionId: submissionId);
  }

  @override
  Future<StudyMaterialSubmission> submitMaterialDraftForReview(
    String submissionId,
  ) {
    submitCalls++;
    if (submitCalls == 1) {
      throw const ContributionSubmissionException('Network unavailable.');
    }
    return super.submitMaterialDraftForReview(submissionId);
  }
}
