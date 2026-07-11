import '../data/mock_learning_data.dart' as mock_data;
import '../models/answer_check_result.dart';
import '../models/answer_review.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'learning_repository.dart';

class MockLearningRepository implements LearningRepository {
  const MockLearningRepository();

  static const Map<String, String> _correctAnswerOptionIdsByQuestionId = {
    'question_js_basics_1': 'js_b1_c',
    'question_js_basics_2': 'js_b2_b',
    'question_js_basics_3': 'js_b3_c',
    'question_js_functions_1': 'js_f1_a',
    'question_js_functions_2': 'js_f2_d',
    'question_js_functions_3': 'js_f3_a',
    'question_java_oop_1': 'java_1_b',
    'question_java_oop_2': 'java_2_a',
    'question_java_oop_3': 'java_3_c',
    'question_database_1': 'db_1_a',
    'question_database_2': 'db_2_b',
    'question_database_3': 'db_3_c',
  };

  @override
  Future<List<Subject>> getSubjects() async {
    return mock_data.mockSubjects;
  }

  @override
  Future<List<Topic>> getTopicsBySubjectId(String subjectId) async {
    return mock_data.getTopicsBySubjectId(subjectId);
  }

  @override
  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId) async {
    return mock_data.getQuestionSetsBySubjectId(subjectId);
  }

  @override
  Future<QuestionSet?> getQuestionSetById(String id) async {
    return mock_data.getQuestionSetById(id);
  }

  @override
  Future<List<Question>> getQuestionsByQuestionSetId(String id) async {
    return mock_data.getQuestionsByQuestionSetId(id);
  }

  @override
  Future<AnswerCheckResult> checkAnswer({
    required String questionId,
    required String selectedAnswerOptionId,
  }) async {
    Question? question;
    for (final candidate in mock_data.mockQuestions) {
      if (candidate.id == questionId) {
        question = candidate;
        break;
      }
    }
    if (question == null) {
      throw StateError('Question $questionId was not found.');
    }

    final selectedAnswerText = _findAnswerText(
      question,
      selectedAnswerOptionId,
    );
    if (selectedAnswerText == null) {
      throw StateError(
        'Answer option $selectedAnswerOptionId does not belong to $questionId.',
      );
    }

    final correctAnswerOptionId =
        _correctAnswerOptionIdsByQuestionId[questionId];
    if (correctAnswerOptionId == null) {
      throw StateError('Missing answer key for question $questionId.');
    }

    final correctAnswerText = _findAnswerText(question, correctAnswerOptionId);
    if (correctAnswerText == null) {
      throw StateError('Invalid answer key for question $questionId.');
    }

    return AnswerCheckResult(
      questionId: questionId,
      selectedAnswerOptionId: selectedAnswerOptionId,
      selectedAnswerText: selectedAnswerText,
      correctAnswerOptionId: correctAnswerOptionId,
      correctAnswerText: correctAnswerText,
      isCorrect: selectedAnswerOptionId == correctAnswerOptionId,
    );
  }

  @override
  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  }) async {
    final questionSet = await getQuestionSetById(questionSetId);
    if (questionSet == null) {
      throw StateError('Question set $questionSetId was not found.');
    }

    final questions = await getQuestionsByQuestionSetId(questionSetId);
    final answerReviews = <AnswerReview>[];

    for (final question in questions) {
      final selectedAnswerOptionId =
          selectedAnswerOptionIdsByQuestionId[question.id];
      final correctAnswerOptionId =
          _correctAnswerOptionIdsByQuestionId[question.id];

      if (correctAnswerOptionId == null) {
        throw StateError('Missing answer key for question ${question.id}.');
      }

      final selectedAnswerText = _findAnswerText(
        question,
        selectedAnswerOptionId,
      );
      final correctAnswerText = _findAnswerText(
        question,
        correctAnswerOptionId,
      );

      if (correctAnswerText == null) {
        throw StateError('Invalid answer key for question ${question.id}.');
      }

      answerReviews.add(
        AnswerReview(
          questionId: question.id,
          questionText: question.text,
          selectedAnswerOptionId: selectedAnswerOptionId,
          selectedAnswerText: selectedAnswerText,
          correctAnswerOptionId: correctAnswerOptionId,
          correctAnswerText: correctAnswerText,
          isCorrect: selectedAnswerOptionId == correctAnswerOptionId,
        ),
      );
    }

    final totalCount = questions.length;
    final correctCount = answerReviews
        .where((answerReview) => answerReview.isCorrect)
        .length;

    return QuizResult(
      questionSetId: questionSetId,
      questionSetTitle: questionSet.title,
      correctCount: correctCount,
      wrongCount: totalCount - correctCount,
      totalCount: totalCount,
      percentageScore: totalCount == 0 ? 0 : correctCount / totalCount * 100,
      answerReviews: List.unmodifiable(answerReviews),
    );
  }

  String? _findAnswerText(Question question, String? answerOptionId) {
    if (answerOptionId == null) {
      return null;
    }

    for (final answerOption in question.answerOptions) {
      if (answerOption.id == answerOptionId) {
        return answerOption.text;
      }
    }

    return null;
  }
}
