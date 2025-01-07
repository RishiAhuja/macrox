import 'package:blog/data/models/firestore/blog_publish_model.dart';

abstract class PublishEvent {}

class InitiatePublishRequest extends PublishEvent {
  final BlogPublishModel requestModel;

  InitiatePublishRequest({required this.requestModel});
}
