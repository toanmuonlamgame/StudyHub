enum StudyMaterialType { pdf, slides, notes, document, link, other }

enum StudyMaterialSourceType { externalLink, uploadedFile }

class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.subjectId,
    this.topicId,
    required this.title,
    required this.description,
    required this.materialType,
    this.language,
    required this.createdAt,
    this.sourceType,
    this.sourceUrl,
    this.fileName,
    this.mimeType,
    this.fileSizeBytes,
    this.updatedAt,
  });

  final String id;
  final String subjectId;
  final String? topicId;
  final String title;
  final String description;
  final StudyMaterialType materialType;
  final String? language;
  final DateTime createdAt;
  final StudyMaterialSourceType? sourceType;
  final String? sourceUrl;
  final String? fileName;
  final String? mimeType;
  final int? fileSizeBytes;
  final DateTime? updatedAt;
}
