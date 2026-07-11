import 'answer_review.dart';
import 'quiz_mode.dart';

class QuizResult {
  const QuizResult({
    required this.questionSetId,
    required this.questionSetTitle,
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    required this.percentageScore,
    required this.answerReviews,
    this.quizMode = QuizMode.exam,
  });

  final String questionSetId;
  final String questionSetTitle;
  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final double percentageScore;
  final List<AnswerReview> answerReviews;
  final QuizMode quizMode;
}
