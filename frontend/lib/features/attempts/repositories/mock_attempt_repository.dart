import '../../learning/repositories/learning_repository.dart';
import '../../learning/repositories/mock_learning_repository.dart';
import '../models/exam_attempt.dart';
import 'attempt_repository.dart';

class MockAttemptRepository extends AttemptRepository {
  MockAttemptRepository({LearningRepository? learningRepository})
    : _learningRepository =
          learningRepository ?? const MockLearningRepository();

  final LearningRepository _learningRepository;
  final Map<String, ExamAttemptDetail> _attemptsBySubmissionId = {};
  int _nextAttemptNumber = 1;

  @override
  Future<ExamAttemptDetail> saveExamAttempt(
    ExamAttemptSaveRequest request,
  ) async {
    final existing = _attemptsBySubmissionId[request.submissionId];
    if (existing != null) {
      if (existing.questionSetId != request.questionSetId) {
        throw StateError('Submission ID belongs to another question set.');
      }
      return existing;
    }

    final result = await _learningRepository.submitQuiz(
      questionSetId: request.questionSetId,
      selectedAnswerOptionIdsByQuestionId:
          request.selectedAnswerOptionIdsByQuestionId,
    );
    final attempt = ExamAttemptDetail(
      id: 'attempt_${_nextAttemptNumber++}',
      questionSetId: result.questionSetId,
      questionSetTitle: result.questionSetTitle,
      startedAt: request.startedAt,
      completedAt: DateTime.now(),
      totalQuestions: result.totalCount,
      correctAnswers: result.correctCount,
      wrongAnswers: result.wrongCount,
      unansweredAnswers: result.unansweredCount,
      percentageScore: result.percentageScore,
      result: result,
    );
    _attemptsBySubmissionId[request.submissionId] = attempt;
    notifyListeners();
    return attempt;
  }

  @override
  Future<List<ExamAttemptSummary>> listExamAttempts() async {
    final attempts = _attemptsBySubmissionId.values.toList(growable: false)
      ..sort(
        (left, right) => right.completedAt.compareTo(left.completedAt) != 0
            ? right.completedAt.compareTo(left.completedAt)
            : right.id.compareTo(left.id),
      );
    return attempts;
  }

  @override
  Future<ExamAttemptDetail?> getExamAttempt(String attemptId) async {
    for (final attempt in _attemptsBySubmissionId.values) {
      if (attempt.id == attemptId) {
        return attempt;
      }
    }
    return null;
  }
}
