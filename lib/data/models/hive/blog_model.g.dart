// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlogModelAdapter extends TypeAdapter<BlogModel> {
  @override
  final int typeId = 0;

  @override
  BlogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlogModel(
      title: fields[0] as String,
      content: fields[1] as String,
      htmlPreview: fields[2] as String,
      uid: fields[3] as String,
      userUid: fields[4] as String,
      publishedTimestamp: fields[5] as bool,
      authorUid: fields[6] as String,
      authors: (fields[7] as List).cast<String>(),
      likedBy: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BlogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.htmlPreview)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.userUid)
      ..writeByte(5)
      ..write(obj.publishedTimestamp)
      ..writeByte(6)
      ..write(obj.authorUid)
      ..writeByte(7)
      ..write(obj.authors)
      ..writeByte(8)
      ..write(obj.likedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
