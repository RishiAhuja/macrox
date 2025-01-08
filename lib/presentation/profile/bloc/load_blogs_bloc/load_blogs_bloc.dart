import 'package:blog/data/models/firestore/profile_blog_model.dart';
import 'package:blog/domain/usecases/firestore/get_profile_blogs_usecase.dart';
import 'package:blog/presentation/profile/bloc/load_blogs_bloc/load_blogs_event.dart';
import 'package:blog/presentation/profile/bloc/load_blogs_bloc/load_blogs_state.dart';
import 'package:blog/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadBlogsBloc extends Bloc<LoadBlogsEvent, LoadBlogsState> {
  LoadBlogsBloc() : super(BlogsInitial()) {
    on<LoadUserBlogs>(_onLoadUserBlogs);
  }
  Future<void> _onLoadUserBlogs(
      LoadUserBlogs event, Emitter<LoadBlogsState> emit) async {
    emit(BlogsLoading());
    final result = await sl<GetProfileBlogsUsecase>()
        .call(params: ProfileBlogModel(author: event.username));
    result.fold((l) {
      emit(BlogsError(l));
    }, (r) {
      emit(BlogsLoaded(r));
    });
  }
}
