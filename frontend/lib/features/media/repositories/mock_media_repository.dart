import 'package:image_picker/image_picker.dart';

import '../../learning/models/media_asset.dart';
import 'media_repository.dart';

class MockMediaRepository implements MediaRepository {
  const MockMediaRepository();
  @override
  Future<MediaAsset> uploadImage(XFile file, {String? altText}) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > imageUploadMaxBytes) {
      throw const MediaUploadException('Image must be 5 MiB or smaller.');
    }
    if (!_isSupported(file.name)) {
      throw const MediaUploadException(
        'Only JPEG, PNG, and WebP images are supported.',
      );
    }
    return MediaAsset(
      mediaType: StudyMediaType.image,
      mediaUrl: 'mock://image/${DateTime.now().microsecondsSinceEpoch}',
      altText: altText,
      previewBytes: bytes,
    );
  }

  bool _isSupported(String name) =>
      RegExp(r'\.(?:jpe?g|png|webp)$', caseSensitive: false).hasMatch(name);
}
