import 'answer_review.dart';

class QuizResult {
  const QuizResult({
    required this.questionSetId,
    required this.questionSetTitle,
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    required this.percentageScore,
    required this.answerReviews,
  });

  final String questionSetId;
  final String questionSetTitle;
  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final double percentageScore;
  final List<AnswerReview> answerReviews;
}
