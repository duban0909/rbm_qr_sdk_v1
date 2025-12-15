import 'package:image_picker/image_picker.dart';

class CameraGallery {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> selectPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 100,
    );
    return image?.path;
  }
}