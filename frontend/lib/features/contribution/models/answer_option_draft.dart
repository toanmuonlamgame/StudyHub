class AnswerOptionDraft {
  const AnswerOptionDraft({
    required this.id,
    this.text = '',
    this.isCorrect = false,
  });

  final String id;
  final String text;
  final bool isCorrect;

  AnswerOptionDraft copyWith({String? text, bool? isCorrect}) {
    return AnswerOptionDraft(
      id: id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
