import 'answer_option.dart';
import 'media_asset.dart';

class Question {
  const Question({
    required this.id,
    required this.questionSetId,
    required this.text,
    this.media,
    required this.answerOptions,
  });

  final String id;
  final String questionSetId;
  final String text;
  final MediaAsset? media;
  final List<AnswerOption> answerOptions;
}
