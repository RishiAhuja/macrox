import 'package:blog/domain/entities/cloud_storage/images/image_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ImageRepository {
  Future<Either<String, ImageEntity>> pickImage();
}
