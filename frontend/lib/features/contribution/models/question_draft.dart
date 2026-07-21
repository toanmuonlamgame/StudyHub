import 'answer_option_draft.dart';
import '../../learning/models/media_asset.dart';

class QuestionDraft {
  const QuestionDraft({
    required this.id,
    this.text = '',
    this.explanation = '',
    this.media,
    this.explanationMedia,
    this.answerOptions = const [],
  });

  final String id;
  final String text;
  final String explanation;
  final MediaAsset? media;
  final MediaAsset? explanationMedia;
  final List<AnswerOptionDraft> answerOptions;

  QuestionDraft copyWith({
    String? text,
    String? explanation,
    Object? media = _unchanged,
    Object? explanationMedia = _unchanged,
    List<AnswerOptionDraft>? answerOptions,
  }) {
    return QuestionDraft(
      id: id,
      text: text ?? this.text,
      explanation: explanation ?? this.explanation,
      media: identical(media, _unchanged) ? this.media : media as MediaAsset?,
      explanationMedia: identical(explanationMedia, _unchanged)
          ? this.explanationMedia
          : explanationMedia as MediaAsset?,
      answerOptions: answerOptions ?? this.answerOptions,
    );
  }
}

const _unchanged = Object();
