import 'package:blog/data/models/hive/blog_model.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:hive/hive.dart';

abstract class HiveService {
  Future<void> addBlog(BlogEntity entity);
  Future<void> updateBlog(BlogEntity entity);
  Future<Map<String, BlogEntity>> getAllBlogs();
  Future<int> clearBox();
}

class HiveServiceImpl extends HiveService {
  final Box<BlogModel> blogBox;

  HiveServiceImpl({required this.blogBox});

  @override
  Future<void> addBlog(BlogEntity entity) async {
    print("added to hive");

    final blogModel = BlogModel(
        uid: entity.uid,
        title: entity.title,
        content: entity.content,
        htmlPreview: entity.htmlPreview,
        userUid: entity.userUid,
        published: entity.published);
    await blogBox.put(blogModel.uid, blogModel);
  }

  @override
  Future<Map<String, BlogEntity>> getAllBlogs() async {
    print("got data from hive");
    final Map<String, BlogEntity> blogMap = {};
    blogBox.values.forEach((model) {
      blogMap[model.uid] = BlogEntity(
          uid: model.uid,
          title: model.title,
          content: model.content,
          htmlPreview: model.htmlPreview,
          userUid: model.userUid,
          published: model.published);
    });

    return blogMap;
  }

  @override
  Future<void> updateBlog(BlogEntity entity) async {
    print("updated data to hive");
    final blogModel = BlogModel(
        uid: entity.uid,
        title: entity.title,
        content: entity.content,
        htmlPreview: entity.htmlPreview,
        userUid: entity.userUid,
        published: entity.published);
    await blogBox.put(entity.uid, blogModel);
  }

  @override
  Future<int> clearBox() async {
    return await blogBox.clear();
  }
}
