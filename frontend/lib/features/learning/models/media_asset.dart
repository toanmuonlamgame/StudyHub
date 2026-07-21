import 'dart:typed_data';

enum StudyMediaType { image, gif, video }

class MediaAsset {
  const MediaAsset({
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.altText,
    this.width,
    this.height,
    this.previewBytes,
  });

  final StudyMediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? altText;
  final int? width;
  final int? height;

  // Local-only preview bytes are never serialized to the backend.
  final Uint8List? previewBytes;

  Map<String, Object?> toJson() => {
    'mediaType': mediaType.name,
    'mediaUrl': _canonicalServerPath(mediaUrl),
    if (thumbnailUrl != null)
      'thumbnailUrl': _canonicalServerPath(thumbnailUrl!),
    if (altText?.trim().isNotEmpty == true) 'altText': altText!.trim(),
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };

  static String _canonicalServerPath(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme ? uri.path : value;
  }
}
