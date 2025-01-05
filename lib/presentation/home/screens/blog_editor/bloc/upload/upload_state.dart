sealed class UploadState {}

class UploadInitial extends UploadState {}

class UploadLoading extends UploadState {}

class UploadSuccess extends UploadState {
  final String imageUrl;
  UploadSuccess({required this.imageUrl});
}

class UploadError extends UploadState {
  final String message;
  UploadError({required this.message});
}
