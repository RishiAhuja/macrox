import 'package:blog/core/configs/constants/app_constants/constants.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/domain/usecases/hive/update_usecase.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_event.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_state.dart';
import 'package:blog/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishBloc extends Bloc<PublishEvent, PublishState> {
  PublishBloc() : super(PublishInitial()) {
    on<InitiatePublishRequest>((event, emit) async {
      try {
        emit(PublishLoading());
        print("Publishing draft");

        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .where('uid', isEqualTo: event.requestModel.authorUid[0])
            .get();

        if (userDoc.docs.isEmpty) {
          emit(PublishFailed(errorMessage: 'User not found'));
          return;
        }

        // Update local storage
        await sl<UpdateUsecase>().call(
            params: BlogEntity(
                userUid: event.requestModel.userUid,
                uid: event.requestModel.blogUid,
                content: event.requestModel.content,
                htmlPreview: "",
                title: event.requestModel.title,
                publishedTimestamp: true));

        // Update user's blog collection
        // await FirebaseFirestore.instance
        //     .collection('Users')
        //     .doc(userDoc.docs.first.id)
        //     .collection('Blogs')
        //     .doc(event.requestModel.blogUid)
        //     .update({
        //   'content': event.requestModel.content,
        //   'title': event.requestModel.title,
        //   'published': true
        // });

        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(userDoc.docs.first.id)
            .collection('Blogs')
            .doc(event.requestModel.blogUid);

        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          // Update existing document
          await docRef.update({
            'content': event.requestModel.content,
            'title': event.requestModel.title,
            'published': true
          });
          print('Document updated');
        } else {
          // Create new document
          await docRef.set({
            'content': event.requestModel.content,
            'title': event.requestModel.title,
            'published': true,
            'createdAt': FieldValue.serverTimestamp(),
            'uid': event.requestModel.blogUid,
          });
          print('Document created');
        }

        // Publish to main collection
        await FirebaseFirestore.instance
            .collection(Constants.blogCollection)
            .doc(event.requestModel.blogUid)
            .set(event.requestModel.toJson());

        print('blog published successfully: ${event.requestModel.blogUid}');
        emit(PublishSuccess());
      } catch (error) {
        emit(PublishFailed(errorMessage: error.toString()));
      }
    });
  }
}
