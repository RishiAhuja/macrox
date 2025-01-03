import 'package:blog/data/models/firestore/follow_model.dart';
import 'package:blog/domain/usecases/firestore/follow_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'follow_event.dart';
part 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  FollowBloc() : super(FollowInitial()) {
    on<FollowUser>((event, emit) async {
      emit(FollowLoading());
      final result = await FollowUsecase().call(
          params: FollowModel(
              followerUid: event.followerUid,
              followingUid: event.followingUid,
              followerUsername: event.followerUsername,
              followingUsername: event.followingUsername));
      result.fold((l) {
        emit(FollowError(l));
      }, (r) {
        emit(FollowSuccess());
        print("successfully followed @${event.followingUsername}");
      });
    });
  }
}
