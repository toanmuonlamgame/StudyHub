import 'answer_option.dart';

class Question {
  const Question({
    required this.id,
    required this.questionSetId,
    required this.text,
    required this.answerOptions,
  });

  final String id;
  final String questionSetId;
  final String text;
  final List<AnswerOption> answerOptions;
}
