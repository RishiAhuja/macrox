import 'package:blog/data/models/auth/no_params.dart';
import 'package:blog/domain/usecases/cloud_storage/pick_image_usecase.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_event.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PickImageUsecase pickImageUseCase;

  ImageBloc({required this.pickImageUseCase}) : super(ImageInitial()) {
    on<PickImageEvent>((event, emit) async {
      emit(ImageLoading());
      final result = await pickImageUseCase(params: NoParams());
      print("Got result: $result");
      result.fold(
        (l) {
          print("Failure case: $l");
          emit(ImageError(message: l));
        },
        (image) {
          print("Success case with image: $image");
          emit(ImagePicked(image: image));
        },
      );
      print("After fold operation");
    });
    on<ResetImageEvent>((event, emit) {
      emit(ImageInitial());
    });
  }
}
