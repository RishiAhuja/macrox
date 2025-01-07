import 'package:blog/domain/usecases/firestore/get_blog_preview.dart';
import 'package:blog/presentation/preview/bloc/preview_event.dart';
import 'package:blog/presentation/preview/bloc/preview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  PreviewBloc() : super(PreviewInitial()) {
    on<LoadBlogPreview>(_onLoadBlogPreview);
  }

  Future<void> _onLoadBlogPreview(
      LoadBlogPreview event, Emitter<PreviewState> emit) async {
    emit(PreviewLoading());
    final result = await GetBlogUsecase().call(params: event.userUid);

    result.fold((l) {
      emit(PreviewError(l));
    }, (r) {
      emit(PreviewLoaded(r));
    });
  }
}
