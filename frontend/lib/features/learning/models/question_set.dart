class QuestionSet {
  const QuestionSet({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.questionCount,
    this.topicId,
    this.estimatedMinutes,
    this.difficulty,
    this.createdAt,
  });

  final String id;
  final String subjectId;
  final String? topicId;
  final String title;
  final String description;
  final int questionCount;
  final int? estimatedMinutes;
  final String? difficulty;
  final DateTime? createdAt;
}
