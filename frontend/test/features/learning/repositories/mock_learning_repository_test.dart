import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';

void main() {
  test(
    'provides mock learning data through the repository interface',
    () async {
      const repository = MockLearningRepository();

      final subjects = await repository.getSubjects();
      expect(subjects, hasLength(3));
      expect(subjects.first.name, 'JavaScript Basics');

      final subjectId = subjects.first.id;
      final topics = await repository.getTopicsBySubjectId(subjectId);
      final questionSets = await repository.getQuestionSetsBySubjectId(
        subjectId,
      );

      expect(topics, hasLength(2));
      expect(questionSets, hasLength(2));

      final questionSet = questionSets.first;
      final questions = await repository.getQuestionsByQuestionSetId(
        questionSet.id,
      );
      final foundQuestionSet = await repository.getQuestionSetById(
        questionSet.id,
      );

      expect(questions, hasLength(3));
      expect(foundQuestionSet?.id, questionSet.id);
      expect(await repository.getQuestionSetById('missing'), isNull);
    },
  );
}
