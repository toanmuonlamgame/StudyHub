import '../models/question.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';

abstract class LearningRepository {
  Future<List<Subject>> getSubjects();

  Future<List<Topic>> getTopicsBySubjectId(String subjectId);

  Future<List<QuestionSet>> getQuestionSetsBySubjectId(String subjectId);

  Future<QuestionSet?> getQuestionSetById(String id);

  Future<List<Question>> getQuestionsByQuestionSetId(String id);
}
