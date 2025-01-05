import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/domain/entities/cloud_storage/images/uploaded_image_entity.dart';
import 'package:firebase_storage/firebase_storage.dart';

sealed class StorageService {
  Future<UploadedImageEntity> uploadFile({
    required UploadImageRequest imageRequest,
  });
}

class StorageServiceImplementation extends StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<UploadedImageEntity> uploadFile({
    required UploadImageRequest imageRequest,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('${imageRequest.folderPath}/${imageRequest.fileName}');

      final metadata = SettableMetadata(
        contentType: _getContentType(imageRequest.fileName),
        // Optional: You can also add custom metadata
        customMetadata: {'uploaded_by': 'app_user'},
      );
      final uploadTask = ref.putData(
        imageRequest.fileBytes,
        metadata,
      );

      final snapshot = await uploadTask;
      final uploadedImageEntity = UploadedImageEntity(
        downloadUrl: await snapshot.ref.getDownloadURL(),
      );

      return uploadedImageEntity;
    } catch (e) {
      throw ('Failed to upload file: $e');
    }
  }

  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // Default content type
    }
  }
}
