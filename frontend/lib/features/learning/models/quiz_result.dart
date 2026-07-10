class QuizResult {
  const QuizResult({
    required this.questionSetId,
    required this.correctCount,
    required this.wrongCount,
    required this.totalCount,
    required this.percentageScore,
  });

  final String questionSetId;
  final int correctCount;
  final int wrongCount;
  final int totalCount;
  final double percentageScore;
}
