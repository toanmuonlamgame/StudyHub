import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/features/auth/auth_controller.dart';
import 'package:frontend/features/auth/auth_session_store.dart';
import 'package:frontend/features/auth/repositories/mock_auth_repository.dart';
import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/saved/repositories/mock_bookmark_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'registered session persists and restores through current-user lookup',
    () async {
      final repository = MockAuthRepository();
      const store = AuthSessionStore();
      final controller = AuthController(repository: repository, store: store);

      expect(
        await controller.register(
          email: 'learner@example.com',
          password: 'strong-password',
          displayName: 'Learner',
        ),
        isTrue,
      );

      final restored = AuthController(repository: repository, store: store);
      await restored.restore();

      expect(restored.isAuthenticated, isTrue);
      expect(restored.user?.email, 'learner@example.com');
    },
  );

  test('invalid stored session is cleared during restore', () async {
    final repository = MockAuthRepository();
    const store = AuthSessionStore();
    final firstController = AuthController(
      repository: repository,
      store: store,
    );
    await firstController.register(
      email: 'learner@example.com',
      password: 'strong-password',
      displayName: 'Learner',
    );

    final restored = AuthController(
      repository: MockAuthRepository(),
      store: store,
    );
    await restored.restore();

    expect(restored.isAuthenticated, isFalse);
    expect(restored.errorCode, 'AUTHENTICATION_REQUIRED');
    expect(await store.load(), isNull);
  });

  test('logout clears the persisted session', () async {
    final repository = MockAuthRepository();
    const store = AuthSessionStore();
    final controller = AuthController(repository: repository, store: store);
    await controller.register(
      email: 'learner@example.com',
      password: 'strong-password',
      displayName: 'Learner',
    );

    await controller.logout();

    expect(controller.isAuthenticated, isFalse);
    expect(await store.load(), isNull);
  });

  test('saving the same Question Set twice creates one bookmark', () async {
    final repository = MockBookmarkRepository();
    const questionSet = QuestionSet(
      id: 'set-1',
      subjectId: 'subject-1',
      title: 'Saved set',
      description: 'A useful set.',
      questionCount: 3,
    );

    await repository.save(questionSet);
    await repository.save(questionSet);

    expect(await repository.listBookmarks(), [questionSet]);
    expect(await repository.contains(questionSet.id), isTrue);
  });
}
