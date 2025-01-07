import 'package:blog/core/configs/constants/app_constants/constants.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_event.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishBloc extends Bloc<PublishEvent, PublishState> {
  PublishBloc() : super(PublishInitial()) {
    on<InitiatePublishRequest>(
        (InitiatePublishRequest event, Emitter<PublishState> emit) async {
      emit(PublishLoading());
      print("Publishing draft");
      await FirebaseFirestore.instance
          .collection(Constants.blogCollection)
          .doc(event.requestModel.blogUid)
          .set(event.requestModel.toJson())
          .then((value) {
        print('blog published successfully: ${event.requestModel.blogUid}');
        emit(PublishSuccess());
      }).catchError((error) {
        emit(PublishFailed(errorMessage: error.toString()));
      });
    });
  }
}
