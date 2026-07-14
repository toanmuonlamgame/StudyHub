import '../../learning/models/quiz_mode.dart';
import '../../learning/models/quiz_result.dart';

class CompletedLearningSession {
  const CompletedLearningSession({
    required this.id,
    required this.questionSetId,
    required this.questionSetTitle,
    required this.quizMode,
    required this.correctCount,
    required this.totalQuestions,
    required this.percentage,
    required this.completedAt,
  });

  factory CompletedLearningSession.fromQuizResult({
    required String id,
    required QuizResult result,
    required DateTime completedAt,
  }) {
    return CompletedLearningSession(
      id: id,
      questionSetId: result.questionSetId,
      questionSetTitle: result.questionSetTitle,
      quizMode: result.quizMode,
      correctCount: result.correctCount,
      totalQuestions: result.totalCount,
      percentage: result.percentageScore,
      completedAt: completedAt,
    );
  }

  factory CompletedLearningSession.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final questionSetId = json['questionSetId'];
    final questionSetTitle = json['questionSetTitle'];
    final quizModeName = json['quizMode'];
    final correctCount = json['correctCount'];
    final totalQuestions = json['totalQuestions'];
    final percentage = json['percentage'];
    final completedAt = json['completedAt'];

    if (id is! String ||
        id.isEmpty ||
        questionSetId is! String ||
        questionSetId.isEmpty ||
        questionSetTitle is! String ||
        quizModeName is! String ||
        correctCount is! int ||
        totalQuestions is! int ||
        percentage is! num ||
        completedAt is! String) {
      throw const FormatException('Invalid completed learning session.');
    }

    final quizMode = QuizMode.values.where((mode) => mode.name == quizModeName);
    final parsedCompletedAt = DateTime.tryParse(completedAt);
    final score = percentage.toDouble();
    if (quizMode.length != 1 ||
        parsedCompletedAt == null ||
        correctCount < 0 ||
        totalQuestions < 0 ||
        correctCount > totalQuestions ||
        !score.isFinite ||
        score < 0 ||
        score > 100) {
      throw const FormatException('Invalid completed learning session.');
    }

    return CompletedLearningSession(
      id: id,
      questionSetId: questionSetId,
      questionSetTitle: questionSetTitle,
      quizMode: quizMode.single,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      percentage: score,
      completedAt: parsedCompletedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'questionSetId': questionSetId,
      'questionSetTitle': questionSetTitle,
      'quizMode': quizMode.name,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  final String id;
  final String questionSetId;
  final String questionSetTitle;
  final QuizMode quizMode;
  final int correctCount;
  final int totalQuestions;
  final double percentage;
  final DateTime completedAt;

  @override
  bool operator ==(Object other) {
    return other is CompletedLearningSession &&
        other.id == id &&
        other.questionSetId == questionSetId &&
        other.questionSetTitle == questionSetTitle &&
        other.quizMode == quizMode &&
        other.correctCount == correctCount &&
        other.totalQuestions == totalQuestions &&
        other.percentage == percentage &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    questionSetId,
    questionSetTitle,
    quizMode,
    correctCount,
    totalQuestions,
    percentage,
    completedAt,
  );
}
