import '../../learning/models/quiz_result.dart';

class ExamAttemptSummary {
  const ExamAttemptSummary({
    required this.id,
    required this.questionSetId,
    required this.questionSetTitle,
    required this.startedAt,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredAnswers,
    required this.percentageScore,
  });

  final String id;
  final String questionSetId;
  final String questionSetTitle;
  final DateTime? startedAt;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredAnswers;
  final double percentageScore;
}

class ExamAttemptDetail extends ExamAttemptSummary {
  const ExamAttemptDetail({
    required super.id,
    required super.questionSetId,
    required super.questionSetTitle,
    required super.startedAt,
    required super.completedAt,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.unansweredAnswers,
    required super.percentageScore,
    required this.result,
  });

  final QuizResult result;
}

class ExamAttemptSaveRequest {
  const ExamAttemptSaveRequest({
    required this.submissionId,
    required this.questionSetId,
    required this.startedAt,
    required this.selectedAnswerOptionIdsByQuestionId,
  });

  final String submissionId;
  final String questionSetId;
  final DateTime startedAt;
  final Map<String, String> selectedAnswerOptionIdsByQuestionId;
}
