// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tale_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TalePageAdapter extends TypeAdapter<TalePage> {
  @override
  final int typeId = 2;

  @override
  TalePage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TalePage(
      id: fields[0] as String?,
      pageNumber: fields[1] as int,
      content: fields[2] as String,
      imageBase64: fields[3] as String?,
      audioPath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TalePage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pageNumber)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.imageBase64)
      ..writeByte(4)
      ..write(obj.audioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TalePageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
