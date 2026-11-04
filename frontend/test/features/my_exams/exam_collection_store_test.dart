import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/my_exams/exam_collections_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('collections persist with bounded unique IDs per account', () async {
    SharedPreferences.setMockInitialValues({});
    final session = Object();
    ExamCollectionStore store(String key) =>
        ExamCollectionStore(accountKey: key, session: session);
    await store('owner').save([
      for (var i = 0; i < 15; i++)
        (
          name: 'Group $i',
          ids: ['first', 'first', for (var j = 0; j < 60; j++) 'exam-$j'],
        ),
    ]);
    final result = await store('owner').load();
    expect(result, hasLength(12));
    expect(result.first.ids, hasLength(50));
    expect(result.first.ids.where((id) => id == 'first'), hasLength(1));
    expect(await store('other').load(), isEmpty);
  });
}
