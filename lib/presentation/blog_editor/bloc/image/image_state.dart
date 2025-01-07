import 'package:blog/domain/entities/cloud_storage/images/image_entity.dart';

abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImagePicked extends ImageState {
  final ImageEntity image;
  ImagePicked({required this.image});
}

class ImageError extends ImageState {
  final String message;
  ImageError({required this.message});
}
