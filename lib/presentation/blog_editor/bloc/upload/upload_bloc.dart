import 'package:blog/domain/usecases/cloud_storage/upload_image_usecase.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_event.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_state.dart';
import 'package:blog/service_locator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(UploadInitial()) {
    on<UploadImageEvent>((event, emit) async {
      emit(UploadLoading());
      await sl<UploadImageUsecase>().call(params: event.imageReq).then((value) {
        value.fold(
          (l) {
            emit(UploadError(message: l));
          },
          (r) {
            emit(UploadSuccess(imageUrl: r.downloadUrl));
          },
        );
      });
    });
  }
}
