import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/models/auth_user.dart';
import 'package:frontend/features/my_exams/recent_exam_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'recent exams are capped, ordered, deduplicated and isolated by account',
    () async {
      SharedPreferences.setMockInitialValues({});
      final created = DateTime.utc(2026);
      RecentExamStore store(String id, DateTime date) => RecentExamStore(
        AuthUser(
          id: id,
          email: 'test@example.test',
          displayName: 'Test',
          createdAt: date,
        ),
      );
      final first = store('account-a', created);
      final other = store('account-b', created);
      final reusedId = store('account-a', DateTime.utc(2027));
      for (var i = 0; i < 12; i++) {
        await first.record('exam-$i');
      }
      await first.record('exam-5');
      final values = await store('account-a', created).load();
      expect(values, hasLength(8));
      expect(values.take(2), ['exam-5', 'exam-11']);
      expect(values.where((id) => id == 'exam-5'), hasLength(1));
      expect(await other.load(), isEmpty);
      expect(await reusedId.load(), isEmpty);
      await first.clear();
      expect(await first.load(), isEmpty);
    },
  );

  test('guest history stays in the current app session only', () async {
    final session = Object();
    await RecentExamStore(null, guestSession: session).record('exam');
    expect(await RecentExamStore(null, guestSession: session).load(), ['exam']);
    expect(await RecentExamStore(null, guestSession: Object()).load(), isEmpty);
  });
}
