import 'package:blog/data/models/cloud_storage/images/image_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class ImageLocalService {
  Future<ImageModel> pickImage();
}

class ImageLocalServiceImplementation extends ImageLocalService {
  @override
  Future<ImageModel> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      return ImageModel(
        bytes: result.files.first.bytes,
        name: result.files.first.name,
      );
    }
    throw 'Failed to pick image';
  }
}
