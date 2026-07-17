import '../data/mock_learning_data.dart' as mock_data;
import '../models/answer_check_result.dart';
import '../models/answer_review.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/paginated_result.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'learning_repository.dart';
import '../../materials/data/mock_study_material_data.dart';
import '../../materials/models/study_material.dart';

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

  static const Map<String, String> _explanationsByQuestionId = {
    'question_js_basics_1':
        '`let` declares a block-scoped variable whose value may be reassigned.',
    'question_js_basics_2':
        '`===` compares both value and type without implicit type conversion.',
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
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 50.');
    }

    final search = q?.trim().toLowerCase();
    final filtered = mock_data.mockQuestionSets
        .where(
          (questionSet) =>
              (subjectId == null || questionSet.subjectId == subjectId) &&
              (topicId == null || questionSet.topicId == topicId) &&
              (search == null ||
                  search.isEmpty ||
                  questionSet.title.toLowerCase().contains(search)),
        )
        .toList(growable: false);

    var startIndex = 0;
    if (cursor != null) {
      final cursorIndex = filtered.indexWhere(
        (questionSet) => questionSet.id == cursor,
      );
      if (cursorIndex == -1) {
        throw StateError('Invalid mock question set cursor.');
      }
      startIndex = cursorIndex + 1;
    }

    final endIndex = (startIndex + limit).clamp(0, filtered.length);
    final items = filtered.sublist(startIndex, endIndex);
    final hasMore = endIndex < filtered.length;

    return PaginatedResult(
      items: List.unmodifiable(items),
      nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<QuestionSet?> getQuestionSetById(String id) async {
    return mock_data.getQuestionSetById(id);
  }

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
    if (limit < 1 || limit > 50) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 50.');
    }
    final search = q?.trim().toLowerCase();
    final filtered = mockStudyMaterials
        .where(
          (material) =>
              (subjectId == null || material.subjectId == subjectId) &&
              (topicId == null || material.topicId == topicId) &&
              (materialType == null || material.materialType == materialType) &&
              (language == null || material.language == language) &&
              (search == null ||
                  search.isEmpty ||
                  material.title.toLowerCase().contains(search) ||
                  material.description.toLowerCase().contains(search)),
        )
        .toList(growable: false);
    var startIndex = 0;
    if (cursor != null) {
      final index = filtered.indexWhere((material) => material.id == cursor);
      if (index == -1) {
        throw StateError('Invalid mock study material cursor.');
      }
      startIndex = index + 1;
    }
    final endIndex = (startIndex + limit).clamp(0, filtered.length);
    final items = filtered.sublist(startIndex, endIndex);
    final hasMore = endIndex < filtered.length;
    return PaginatedResult(
      items: List.unmodifiable(items),
      nextCursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<StudyMaterial?> getStudyMaterialById(String id) async {
    for (final material in mockStudyMaterials) {
      if (material.id == id) {
        return material;
      }
    }
    return null;
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
      explanation: _explanationsByQuestionId[questionId],
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
    final questionIds = questions.map((question) => question.id).toSet();
    for (final questionId in selectedAnswerOptionIdsByQuestionId.keys) {
      if (!questionIds.contains(questionId)) {
        throw StateError(
          'Question $questionId does not belong to question set $questionSetId.',
        );
      }
    }

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
      if (selectedAnswerOptionId != null && selectedAnswerText == null) {
        throw StateError(
          'Answer option $selectedAnswerOptionId does not belong to question ${question.id}.',
        );
      }
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
          answerOptions: question.answerOptions,
          selectedAnswerOptionId: selectedAnswerOptionId,
          selectedAnswerText: selectedAnswerText,
          correctAnswerOptionId: correctAnswerOptionId,
          correctAnswerText: correctAnswerText,
          isCorrect: selectedAnswerOptionId == correctAnswerOptionId,
          explanation: _explanationsByQuestionId[question.id],
        ),
      );
    }

    return QuizResult.fromTrustedReviews(
      questionSetId: questionSetId,
      questionSetTitle: questionSet.title,
      totalCount: questions.length,
      answerReviews: answerReviews,
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
