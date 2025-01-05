import 'package:flutter/foundation.dart';

class ImageEntity {
  final Uint8List? bytes;
  final String? path;
  final String name;

  ImageEntity({
    this.bytes,
    this.path,
    required this.name,
  });
}
