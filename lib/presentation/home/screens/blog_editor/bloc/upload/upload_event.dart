import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';

sealed class UploadEvent {}

class UploadImageEvent extends UploadEvent {
  final UploadImageRequest imageReq;
  UploadImageEvent({required this.imageReq});
}
