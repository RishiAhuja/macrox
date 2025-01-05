import 'package:blog/core/usecase/usecase.dart';
import 'package:blog/data/models/auth/no_params.dart';
import 'package:blog/domain/repository/cloud_storage/images/image_repository.dart';
import 'package:blog/service_locator.dart';
import 'package:dartz/dartz.dart';

class PickImageUsecase implements Usecase<Either, NoParams> {
  @override
  Future<Either> call({NoParams? params}) {
    return sl<ImageRepository>().pickImage();
  }
}
