import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../learning/models/media_asset.dart';
import '../../media/repositories/media_repository.dart';

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
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    if (!RegExp(
      r'\.(?:jpe?g|png|webp)$',
      caseSensitive: false,
    ).hasMatch(file.name)) {
      throw const AvatarValidationException(
        AvatarValidationIssue.unsupportedType,
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > imageUploadMaxBytes) {
      throw const AvatarValidationException(AvatarValidationIssue.fileTooLarge);
    }
    return SelectedAvatar(file: file, bytes: bytes);
  }

  Future<MediaAsset> upload(SelectedAvatar avatar, {String? altText}) =>
      mediaRepository.uploadImage(avatar.file, altText: altText);
}

enum AvatarValidationIssue { unsupportedType, fileTooLarge }

class AvatarValidationException implements Exception {
  const AvatarValidationException(this.issue);
  final AvatarValidationIssue issue;
}
