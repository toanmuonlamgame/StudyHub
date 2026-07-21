import 'package:image_picker/image_picker.dart';

abstract interface class ImageSelectionService {
  Future<XFile?> chooseFromGallery();
  Future<XFile?> recoverLostImage();
}

class DeviceImageSelectionService implements ImageSelectionService {
  DeviceImageSelectionService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  @override
  Future<XFile?> chooseFromGallery() => _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 85,
    requestFullMetadata: false,
  );

  @override
  Future<XFile?> recoverLostImage() async {
    final response = await _picker.retrieveLostData();
    return response.files?.firstOrNull;
  }
}
