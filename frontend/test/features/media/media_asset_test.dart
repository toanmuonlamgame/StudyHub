import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/contribution/models/question_draft.dart';
import 'package:frontend/features/contribution/models/question_set_draft.dart';
import 'package:frontend/features/learning/models/media_asset.dart';

void main() {
  test('contribution media serializes only canonical server metadata', () {
    const media = MediaAsset(
      mediaType: StudyMediaType.image,
      mediaUrl: 'http://10.0.2.2:3000/media/images/safe.png',
      altText: 'Database diagram',
      width: 800,
      height: 600,
    );
    const draft = QuestionSetDraft(
      subjectId: 'subject_database',
      title: 'Database set',
      questions: [
        QuestionDraft(id: 'q1', text: 'Read the diagram', media: media),
      ],
    );
    final question = (draft.toJson()['questions'] as List).single as Map;
    final json = question['media'] as Map;

    expect(json['mediaUrl'], '/media/images/safe.png');
    expect(json['mediaType'], 'image');
    expect(json.containsKey('previewBytes'), isFalse);
  });
}
