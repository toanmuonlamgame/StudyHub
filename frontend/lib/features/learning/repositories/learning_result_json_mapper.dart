import '../models/answer_option.dart';
import '../models/answer_review.dart';
import '../models/quiz_result.dart';
import 'media_asset_json_mapper.dart';

QuizResult quizResultFromJson(Map<String, dynamic> json, {Uri? mediaBaseUri}) {
  return QuizResult(
    questionSetId: _readString(json, 'questionSetId'),
    questionSetTitle: _readString(json, 'questionSetTitle'),
    totalCount: _readInt(json, 'totalQuestions'),
    correctCount: _readInt(json, 'correctAnswers'),
    wrongCount: _readInt(json, 'wrongAnswers'),
    unansweredCount: _readInt(json, 'unansweredAnswers'),
    percentageScore: _readDouble(json, 'percentageScore'),
    answerReviews: _readObjectList(json, 'answerReviews')
        .map((item) => _answerReviewFromJson(item, mediaBaseUri: mediaBaseUri))
        .toList(growable: false),
  );
}

AnswerReview _answerReviewFromJson(
  Map<String, dynamic> json, {
  Uri? mediaBaseUri,
}) {
  return AnswerReview(
    questionId: _readString(json, 'questionId'),
    questionText: _readString(json, 'questionText'),
    answerOptions: _readObjectList(json, 'answerOptions')
        .map(
          (option) => AnswerOption(
            id: _readString(option, 'id'),
            text: _readString(option, 'text'),
          ),
        )
        .toList(growable: false),
    selectedAnswerOptionId: _readNullableString(json, 'selectedAnswerOptionId'),
    selectedAnswerText: _readNullableString(json, 'selectedAnswerText'),
    correctAnswerOptionId: _readString(json, 'correctAnswerOptionId'),
    correctAnswerText: _readString(json, 'correctAnswerText'),
    isCorrect: _readBool(json, 'isCorrect'),
    explanation: _readNullableString(json, 'explanation'),
    questionMedia: mediaAssetFromJson(
      json['questionMedia'],
      baseUri: mediaBaseUri,
    ),
    explanationMedia: mediaAssetFromJson(
      json['explanationMedia'],
      baseUri: mediaBaseUri,
    ),
  );
}

List<Map<String, dynamic>> _readObjectList(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected $key to be a list.');
  }
  return value
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('Expected $key to contain objects.');
        }
        return item;
      })
      .toList(growable: false);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Expected $key to be a string.');
  }
  return value;
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Expected $key to be nullable text.');
  }
  return value;
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Expected $key to be an integer.');
  }
  return value;
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('Expected $key to be a number.');
  }
  return value.toDouble();
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('Expected $key to be a boolean.');
  }
  return value;
}
