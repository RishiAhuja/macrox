abstract class PublishState {}

class PublishInitial extends PublishState {}

class PublishLoading extends PublishState {}

class PublishSuccess extends PublishState {}

class PublishFailed extends PublishState {
  final String errorMessage;
  PublishFailed({required this.errorMessage});
}
