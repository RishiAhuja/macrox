import 'package:flutter/foundation.dart';

class UploadImageRequest {
  final Uint8List fileBytes;
  final String fileName;
  final String folderPath;

  UploadImageRequest(
      {required this.fileBytes,
      required this.fileName,
      required this.folderPath});
}
