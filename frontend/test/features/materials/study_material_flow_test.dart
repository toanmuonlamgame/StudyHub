import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/models/paginated_result.dart';
import 'package:frontend/features/materials/models/study_material.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('opens Study Materials from Home and browses safe detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await _openMaterials(tester);
    expect(find.text('Bai tap SQL co ban'), findsOneWidget);
    expect(find.text('Java inheritance slides'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('material-search-field')),
      'normalization',
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(find.text('Database normalization notes'), findsOneWidget);
    expect(find.text('Java inheritance slides'), findsNothing);

    await tester.tap(find.text('Database normalization notes'));
    await tester.pumpAndSettle();
    expect(find.text('External resource'), findsOneWidget);
    expect(find.textContaining('postgresql.org'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('shows a retry state when material detail cannot load', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(
        learningRepository: _FailingMaterialDetailRepository(),
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );

    await _openMaterials(tester);
    await tester.tap(find.text('Bai tap SQL co ban'));
    await tester.pumpAndSettle();
    expect(find.text('Study materials could not be loaded'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows honest uploaded-file and no-results states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );

    await _openMaterials(tester);
    await tester.tap(find.text('Bai tap SQL co ban'));
    await tester.pumpAndSettle();
    expect(find.text('Uploaded file'), findsOneWidget);
    expect(
      find.text('This file is not available in the prototype yet.'),
      findsOneWidget,
    );
    expect(find.textContaining('Download'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('material-search-field')),
      'not-a-real-material',
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(find.text('No study materials yet'), findsOneWidget);
  });

  testWidgets('retries a failed material list request', (tester) async {
    final repository = _RetryMaterialListRepository();
    await tester.pumpWidget(
      StudyHubApp(
        learningRepository: repository,
        initialLocaleSelection: AppLocaleSelection.english,
      ),
    );

    await _openMaterials(tester);
    expect(find.text('Study materials could not be loaded'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Bai tap SQL co ban'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('materials flow is localized and fits compact scaled text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: StudyHubApp(
          initialLocaleSelection: AppLocaleSelection.vietnamese,
        ),
      ),
    );

    await _openMaterials(tester, label: 'Tài liệu học tập');
    expect(find.text('Tìm tài liệu học tập'), findsOneWidget);
    expect(find.text('Tất cả định dạng'), findsOneWidget);
  });
}

Future<void> _openMaterials(
  WidgetTester tester, {
  String label = 'Study Materials',
}) async {
  final tile = find.text(label);
  final scrollable = find
      .descendant(
        of: find.byKey(const ValueKey('home-hub-list')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .first;
  await tester.scrollUntilVisible(tile, 300, scrollable: scrollable);
  await tester.drag(scrollable, const Offset(0, -180));
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

class _FailingMaterialDetailRepository extends MockLearningRepository {
  const _FailingMaterialDetailRepository();

  @override
  Future<StudyMaterial?> getStudyMaterialById(String id) async {
    throw StateError('Material unavailable.');
  }
}

class _RetryMaterialListRepository extends MockLearningRepository {
  int calls = 0;

  @override
  Future<PaginatedResult<StudyMaterial>> listStudyMaterials({
    String? subjectId,
    String? topicId,
    String? q,
    StudyMaterialType? materialType,
    String? language,
    int limit = 20,
    String? cursor,
  }) async {
    calls++;
    if (calls == 1) {
      throw StateError('Temporary list failure.');
    }
    return super.listStudyMaterials(
      subjectId: subjectId,
      topicId: topicId,
      q: q,
      materialType: materialType,
      language: language,
      limit: limit,
      cursor: cursor,
    );
  }
}
