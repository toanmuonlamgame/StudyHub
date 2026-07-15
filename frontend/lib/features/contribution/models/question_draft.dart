import 'answer_option_draft.dart';

class QuestionDraft {
  const QuestionDraft({
    required this.id,
    this.text = '',
    this.explanation = '',
    this.answerOptions = const [],
  });

  final String id;
  final String text;
  final String explanation;
  final List<AnswerOptionDraft> answerOptions;

  QuestionDraft copyWith({
    String? text,
    String? explanation,
    List<AnswerOptionDraft>? answerOptions,
  }) {
    return QuestionDraft(
      id: id,
      text: text ?? this.text,
      explanation: explanation ?? this.explanation,
      answerOptions: answerOptions ?? this.answerOptions,
    );
  }
}
