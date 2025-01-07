import 'package:blog/domain/entities/blog/blog_preview_entity.dart';

abstract class PreviewState {}

class PreviewInitial extends PreviewState {}

class PreviewLoading extends PreviewState {}

class PreviewLoaded extends PreviewState {
  final BlogPreviewEntity blogEntity;
  PreviewLoaded(this.blogEntity);
}

class PreviewError extends PreviewState {
  final String message;
  PreviewError(this.message);
}
