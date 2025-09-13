part of 'video_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoDataAdapter extends TypeAdapter<VideoData> {
  @override
  final int typeId = 0;

  @override
  VideoData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoData(
      isLiked: fields[0] as bool,
      likeCount: fields[1] as int,
      comments: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VideoData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isLiked)
      ..writeByte(1)
      ..write(obj.likeCount)
      ..writeByte(2)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VideoDataAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}