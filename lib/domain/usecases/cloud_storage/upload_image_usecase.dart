import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/domain/repository/cloud_storage/storage/storage_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class UploadImageUsecase extends Usecase<Either, UploadImageRequest> {
  @override
  Future<Either> call({UploadImageRequest? params}) {
    return sl<StorageRepository>().uploadFile(createStorageRequest: params!);
  }
}
