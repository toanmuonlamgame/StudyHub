import 'answer_review.dart';
import 'quiz_mode.dart';

class QuizResult {
  const QuizResult({
    required this.questionSetId,
    required this.questionSetTitle,
    required this.correctCount,
    required this.wrongCount,
    this.unansweredCount = 0,
    required this.totalCount,
    required this.percentageScore,
    required this.answerReviews,
    this.quizMode = QuizMode.exam,
  });

  final String questionSetId;
  final String questionSetTitle;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final int totalCount;
  final double percentageScore;
  final List<AnswerReview> answerReviews;
  final QuizMode quizMode;

  factory QuizResult.fromTrustedReviews({
    required String questionSetId,
    required String questionSetTitle,
    required int totalCount,
    required List<AnswerReview> answerReviews,
    QuizMode quizMode = QuizMode.exam,
  }) {
    if (answerReviews.length != totalCount) {
      throw StateError('Every question must have one trusted answer review.');
    }

    final questionIds = answerReviews
        .map((review) => review.questionId)
        .toSet();
    if (questionIds.length != totalCount) {
      throw StateError('Answer reviews must have unique question ids.');
    }

    final correctCount = answerReviews
        .where((review) => review.status == AnswerReviewStatus.correct)
        .length;
    final wrongCount = answerReviews
        .where((review) => review.status == AnswerReviewStatus.incorrect)
        .length;
    final unansweredCount = answerReviews
        .where((review) => review.status == AnswerReviewStatus.unanswered)
        .length;

    return QuizResult(
      questionSetId: questionSetId,
      questionSetTitle: questionSetTitle,
      correctCount: correctCount,
      wrongCount: wrongCount,
      unansweredCount: unansweredCount,
      totalCount: totalCount,
      percentageScore: totalCount == 0
          ? 0
          : (correctCount / totalCount * 100).roundToDouble(),
      answerReviews: List.unmodifiable(answerReviews),
      quizMode: quizMode,
    );
  }
}
