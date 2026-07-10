import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'learning_repository.dart';

/// Future adapter for the StudyHub Fastify API.
///
/// The V1 local prototype still uses `MockLearningRepository`. Pre-submit API
/// data must not expose correct answers, and [submitQuiz] will use backend
/// scoring when the Fastify endpoints are available.
class ApiLearningRepository implements LearningRepository {
  const ApiLearningRepository();

  @override
  Future<List<Subject>> getSubjects() {
    throw UnimplementedError(
      'ApiLearningRepository.getSubjects is not implemented yet.',
    );
  }

  @override
  Future<List<Topic>> getTopicsBySubjectId(String subjectId) {
    throw UnimplementedError(
      'ApiLearningRepository.getTopicsBySubjectId is not implemented yet.',
    );
  }

  @override
  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId) {
    throw UnimplementedError(
      'ApiLearningRepository.getQuestionSetsBySubjectId is not implemented yet.',
    );
  }

  @override
  Future<QuestionSet?> getQuestionSetById(String id) {
    throw UnimplementedError(
      'ApiLearningRepository.getQuestionSetById is not implemented yet.',
    );
  }

  @override
  Future<List<Question>> getQuestionsByQuestionSetId(String id) {
    throw UnimplementedError(
      'ApiLearningRepository.getQuestionsByQuestionSetId is not implemented yet.',
    );
  }

  @override
  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  }) {
    throw UnimplementedError(
      'ApiLearningRepository.submitQuiz is not implemented yet.',
    );
  }
}
