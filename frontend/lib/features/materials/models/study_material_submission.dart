import 'study_material.dart';

enum StudyMaterialSubmissionStatus { draft, pendingReview, published, rejected }

class StudyMaterialDraft {
  const StudyMaterialDraft({
    required this.subjectId,
    this.topicId,
    required this.title,
    required this.description,
    required this.materialType,
    required this.sourceUrl,
    this.language,
  });

  final String subjectId;
  final String? topicId;
  final String title;
  final String description;
  final StudyMaterialType materialType;
  final String sourceUrl;
  final String? language;

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    if (topicId != null) 'topicId': topicId,
    'title': title.trim(),
    'description': description.trim(),
    'materialType': materialType.name,
    'sourceType': 'externalLink',
    'sourceUrl': sourceUrl.trim(),
    if (language?.trim().isNotEmpty == true)
      'language': language!.trim().toLowerCase(),
  };
}

class StudyMaterialSubmission {
  const StudyMaterialSubmission({
    required this.id,
    required this.draft,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String id;
  final StudyMaterialDraft draft;
  final StudyMaterialSubmissionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  bool get canEdit => status == StudyMaterialSubmissionStatus.draft;
}
