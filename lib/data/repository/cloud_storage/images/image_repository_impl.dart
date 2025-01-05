import 'package:blog/data/sources/cloud_storage/images/image_picker_service.dart';
import 'package:blog/domain/entities/cloud_storage/images/image_entity.dart';
import 'package:blog/domain/repository/cloud_storage/images/image_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class ImageRepositoryImpl implements ImageRepository {
  final localDataSource = sl<ImageLocalService>();

  @override
  Future<Either<String, ImageEntity>> pickImage() async {
    try {
      final image = await localDataSource.pickImage();
      return Right(image);
    } catch (e) {
      return Left('Failed to pick image: ${e.toString()}');
    }
  }
}
