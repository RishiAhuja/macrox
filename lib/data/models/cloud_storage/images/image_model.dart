import 'dart:typed_data';
import 'package:blog/domain/entities/cloud_storage/images/image_entity.dart';
import 'package:file_picker/file_picker.dart';

class ImageModel extends ImageEntity {
  ImageModel({
    Uint8List? bytes,
    required String name,
  }) : super(
          bytes: bytes,
          name: name,
        );

  factory ImageModel.fromFile(PlatformFile file) {
    return ImageModel(
      bytes: file.bytes,
      name: file.name,
    );
  }

  factory ImageModel.empty() {
    return ImageModel(
      bytes: null,
      name: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bytes': bytes,
      'path': path,
      'name': name,
    };
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      bytes: json['bytes'],
      name: json['name'],
    );
  }
}
