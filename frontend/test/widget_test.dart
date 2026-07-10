import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/studyhub_app.dart';

void main() {
  testWidgets('shows the StudyHub V1 skeleton', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyHubApp());

    expect(find.text('StudyHub'), findsWidgets);
    expect(find.text('Subject'), findsOneWidget);
    expect(find.text('Question Sets'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('Upload Placeholder'), findsOneWidget);
  });
}
