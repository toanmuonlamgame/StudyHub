import 'package:image_picker/image_picker.dart';

import '../../learning/models/media_asset.dart';

const imageUploadMaxBytes = 5 * 1024 * 1024;

abstract interface class MediaRepository {
  Future<MediaAsset> uploadImage(XFile file, {String? altText});
}

class MediaUploadException implements Exception {
  const MediaUploadException(this.message);
  final String message;
  @override
  String toString() => message;
}
