import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/domain/entities/cloud_storage/images/uploaded_image_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StorageRepository {
  Future<Either<String, UploadedImageEntity>> uploadFile({
    required UploadImageRequest createStorageRequest,
  });
}
