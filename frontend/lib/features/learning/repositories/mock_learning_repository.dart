import '../data/mock_learning_data.dart' as mock_data;
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'learning_repository.dart';

class MockLearningRepository implements LearningRepository {
  const MockLearningRepository();

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
}
