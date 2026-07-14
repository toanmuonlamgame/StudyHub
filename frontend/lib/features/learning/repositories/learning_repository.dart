import '../models/answer_check_result.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/paginated_result.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../../materials/models/study_material.dart';

abstract class LearningRepository {
  Future<List<Subject>> getSubjects();

  Future<List<Topic>> getTopicsBySubjectId(String subjectId);

  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId);

  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  });

  Future<QuestionSet?> getQuestionSetById(String id);

  Future<PaginatedResult<StudyMaterial>> listStudyMaterials({
    String? subjectId,
    String? topicId,
    String? q,
    StudyMaterialType? materialType,
    String? language,
    int limit = 20,
    String? cursor,
  });

  Future<StudyMaterial?> getStudyMaterialById(String id);

  Future<List<Question>> getQuestionsByQuestionSetId(String id);

  Future<AnswerCheckResult> checkAnswer({
    required String questionId,
    required String selectedAnswerOptionId,
  });

  Future<QuizResult> submitQuiz({
    required String questionSetId,
    required Map<String, String> selectedAnswerOptionIdsByQuestionId,
  });
}
