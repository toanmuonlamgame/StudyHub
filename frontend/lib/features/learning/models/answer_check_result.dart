import 'media_asset.dart';

class AnswerCheckResult {
  const AnswerCheckResult({
    required this.questionId,
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
  final String selectedAnswerOptionId;
  final String selectedAnswerText;
  final String correctAnswerOptionId;
  final String correctAnswerText;
  final bool isCorrect;
  final String? explanation;
  final MediaAsset? questionMedia;
  final MediaAsset? explanationMedia;
}
