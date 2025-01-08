import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_event.dart';
import 'package:blog/presentation/profile/bloc/edit_profile_bloc/edit_profile_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial()) {
    on<UpdateProfile>((event, emit) async {
      emit(EditProfileLoading());
      final db = FirebaseFirestore.instance;
      await db
          .collection('Users')
          .where('username', isEqualTo: event.username)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          await db.collection('Users').doc(value.docs[0].data()['uid']).update({
            'name': event.name,
            'bio': event.bio,
            'socials': event.socials,
          }).then((value) {
            emit(EditProfileSuccess());
          }).catchError((error) {
            emit(EditProfileError(error.toString()));
          });
        } else {
          EditProfileError('Username not found');
        }
      });
    });
  }
}
