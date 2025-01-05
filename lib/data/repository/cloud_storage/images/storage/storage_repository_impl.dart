import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/data/sources/cloud_storage/storage/storage_service.dart';
import 'package:blog/domain/entities/cloud_storage/images/uploaded_image_entity.dart';
import 'package:blog/domain/repository/cloud_storage/storage/storage_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class StorageRepositoryImpl implements StorageRepository {
  final _storageService = sl<StorageService>();
  @override
  Future<Either<String, UploadedImageEntity>> uploadFile(
      {required UploadImageRequest createStorageRequest}) async {
    try {
      final uploadedImageEntity = await _storageService.uploadFile(
        imageRequest: createStorageRequest,
      );

      return Right(uploadedImageEntity);
    } catch (e) {
      return Left('Failed to Upload Image: ${e.toString()}');
    }
  }
}
