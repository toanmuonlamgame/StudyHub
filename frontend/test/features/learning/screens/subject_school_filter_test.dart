import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/learning/models/subject.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/screens/subject_list_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  testWidgets('school filters only subjects with that school', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SubjectListScreen(learningRepository: _Schools()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All schools'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('North School').last);
    await tester.pumpAndSettle();
    expect(find.text('Networking'), findsOneWidget);
    expect(find.text('English Fundamentals'), findsNothing);
  });
}

class _Schools extends MockLearningRepository {
  const _Schools();

  @override
  Future<List<Subject>> getSubjects() async => const [
    Subject(id: 'network', name: 'Networking', school: 'North School'),
    Subject(
      id: 'english',
      name: 'English Fundamentals',
      school: 'South School',
    ),
  ];
}
