import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../learning/models/media_asset.dart';
import '../../media/repositories/media_repository.dart';
import '../../media/services/picker_cache.dart';

class SelectedAvatar {
  const SelectedAvatar({required this.file, required this.bytes});

  final XFile file;
  final Uint8List bytes;
}

class AvatarService {
  AvatarService({required this.mediaRepository, ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final MediaRepository mediaRepository;
  final ImagePicker _imagePicker;

  Future<SelectedAvatar?> chooseFromGallery() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    try {
      if (!RegExp(
        r'\.(?:jpe?g|png|webp)$',
        caseSensitive: false,
      ).hasMatch(file.name)) {
        throw const AvatarValidationException(
          AvatarValidationIssue.unsupportedType,
        );
      }
      if (await file.length() > imageUploadMaxBytes) {
        throw const AvatarValidationException(
          AvatarValidationIssue.fileTooLarge,
        );
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > imageUploadMaxBytes) {
        throw const AvatarValidationException(
          AvatarValidationIssue.fileTooLarge,
        );
      }
      return SelectedAvatar(file: file, bytes: bytes);
    } catch (_) {
      await discardPickedImage(file.path);
      rethrow;
    }
  }

  Future<MediaAsset> upload(SelectedAvatar avatar, {String? altText}) =>
      mediaRepository.uploadImage(avatar.file, altText: altText);

  Future<void> discard(SelectedAvatar avatar) =>
      discardPickedImage(avatar.file.path);
}

enum AvatarValidationIssue { unsupportedType, fileTooLarge }

class AvatarValidationException implements Exception {
  const AvatarValidationException(this.issue);
  final AvatarValidationIssue issue;
}
