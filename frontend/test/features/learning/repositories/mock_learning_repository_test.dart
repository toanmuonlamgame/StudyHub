import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/learning/models/answer_option.dart';
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

  test('returns quiz-safe answer options before submission', () async {
    const repository = MockLearningRepository();
    const publicAnswerOption = AnswerOption(id: 'option_1', text: 'Option 1');
    final subjects = await repository.getSubjects();
    final questionSets = await repository.getQuestionSetsBySubjectId(
      subjects.first.id,
    );
    final questions = await repository.getQuestionsByQuestionSetId(
      questionSets.first.id,
    );

    expect(publicAnswerOption.id, 'option_1');
    expect(publicAnswerOption.text, 'Option 1');
    expect(questions, isNotEmpty);
    expect(
      questions.expand((question) => question.answerOptions),
      everyElement(
        isA<AnswerOption>()
            .having((option) => option.id, 'id', isNotEmpty)
            .having((option) => option.text, 'text', isNotEmpty),
      ),
    );
  });

  test('calculates quiz results from selected answer option ids', () async {
    const repository = MockLearningRepository();
    final subjects = await repository.getSubjects();
    final questionSets = await repository.getQuestionSetsBySubjectId(
      subjects.first.id,
    );
    final questionSet = questionSets.first;
    final questions = await repository.getQuestionsByQuestionSetId(
      questionSet.id,
    );

    final selectedAnswerIds = <String, String>{
      questions[0].id: 'js_b1_b',
      questions[1].id: 'js_b2_b',
      questions[2].id: 'js_b3_c',
    };

    final result = await repository.submitQuiz(
      questionSetId: questionSet.id,
      selectedAnswerOptionIdsByQuestionId: selectedAnswerIds,
    );

    expect(result.questionSetId, questionSet.id);
    expect(result.questionSetTitle, questionSet.title);
    expect(result.correctCount, 2);
    expect(result.wrongCount, 1);
    expect(result.totalCount, 3);
    expect(result.percentageScore, closeTo(66.67, 0.01));
    expect(result.answerReviews, hasLength(3));
    expect(result.answerReviews.first.questionId, questions.first.id);
    expect(result.answerReviews.first.selectedAnswerText, 'const');
    expect(result.answerReviews.first.correctAnswerText, 'let');
    expect(result.answerReviews.first.isCorrect, isFalse);
    expect(result.answerReviews[1].isCorrect, isTrue);

    for (final answerReview in result.answerReviews) {
      expect(answerReview.questionText, isNotEmpty);
      expect(
        answerReview.selectedAnswerOptionId,
        selectedAnswerIds[answerReview.questionId],
      );
      expect(answerReview.selectedAnswerText, isNotEmpty);
      expect(answerReview.correctAnswerOptionId, isNotEmpty);
      expect(answerReview.correctAnswerText, isNotEmpty);
    }
  });

  test('paginates and filters mock question sets', () async {
    const repository = MockLearningRepository();

    final firstPage = await repository.listQuestionSets(
      subjectId: 'subject_javascript',
      limit: 1,
    );
    final secondPage = await repository.listQuestionSets(
      subjectId: 'subject_javascript',
      limit: 1,
      cursor: firstPage.nextCursor,
    );
    final searchPage = await repository.listQuestionSets(
      topicId: 'topic_js_functions',
      q: 'functions',
    );

    expect(firstPage.items, hasLength(1));
    expect(firstPage.hasMore, isTrue);
    expect(firstPage.nextCursor, isNotNull);
    expect(secondPage.items, hasLength(1));
    expect(secondPage.hasMore, isFalse);
    expect(secondPage.items.single.id, isNot(firstPage.items.single.id));
    expect(searchPage.items.single.id, 'question_set_js_functions');
  });

  test('keeps pagination stable, unique, and empty-search aware', () async {
    const repository = MockLearningRepository();

    final firstRun = await repository.listQuestionSets(limit: 2);
    final repeatedRun = await repository.listQuestionSets(limit: 2);
    final secondPage = await repository.listQuestionSets(
      limit: 2,
      cursor: firstRun.nextCursor,
    );
    final emptySearch = await repository.listQuestionSets(q: 'missing title');

    expect(
      repeatedRun.items.map((item) => item.id),
      orderedEquals(firstRun.items.map((item) => item.id)),
    );
    final ids = [
      ...firstRun.items,
      ...secondPage.items,
    ].map((item) => item.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(emptySearch.items, isEmpty);
    expect(emptySearch.hasMore, isFalse);
    expect(emptySearch.nextCursor, isNull);
  });

  test('checks a practice answer and returns correctness afterward', () async {
    const repository = MockLearningRepository();

    final correctResult = await repository.checkAnswer(
      questionId: 'question_js_basics_1',
      selectedAnswerOptionId: 'js_b1_c',
    );
    final wrongResult = await repository.checkAnswer(
      questionId: 'question_js_basics_1',
      selectedAnswerOptionId: 'js_b1_b',
    );

    expect(correctResult.isCorrect, isTrue);
    expect(correctResult.selectedAnswerText, 'let');
    expect(correctResult.correctAnswerOptionId, 'js_b1_c');
    expect(wrongResult.isCorrect, isFalse);
    expect(wrongResult.selectedAnswerText, 'const');
    expect(wrongResult.correctAnswerText, 'let');
  });
}
