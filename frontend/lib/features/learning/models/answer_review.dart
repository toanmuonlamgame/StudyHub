import 'answer_option.dart';
import 'media_asset.dart';

enum AnswerReviewStatus { correct, incorrect, unanswered }

class AnswerReview {
  const AnswerReview({
    required this.questionId,
    required this.questionText,
    this.answerOptions = const [],
    required this.selectedAnswerOptionId,
    required this.selectedAnswerText,
    required this.correctAnswerOptionId,
    required this.correctAnswerText,
    required this.isCorrect,
    this.explanation,
    this.questionMedia,
    this.explanationMedia,
  });

  final String questionId;
  final String questionText;
  final List<AnswerOption> answerOptions;
  final String? selectedAnswerOptionId;
  final String? selectedAnswerText;
  final String correctAnswerOptionId;
  final String correctAnswerText;
  final bool isCorrect;
  final String? explanation;
  final MediaAsset? questionMedia;
  final MediaAsset? explanationMedia;

  AnswerReviewStatus get status {
    if (selectedAnswerOptionId == null) {
      return AnswerReviewStatus.unanswered;
    }
    return isCorrect
        ? AnswerReviewStatus.correct
        : AnswerReviewStatus.incorrect;
  }
}
