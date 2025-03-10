// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaleAdapter extends TypeAdapter<Tale> {
  @override
  final int typeId = 1;

  @override
  Tale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tale(
      id: fields[0] as String?,
      title: fields[1] as String,
      theme: fields[2] as String,
      setting: fields[3] as String,
      wordCount: fields[4] as int,
      userId: fields[5] as String,
      pages: (fields[6] as List).cast<TalePage>(),
      createdAt: fields[7] as DateTime?,
      isFavorite: fields[8] as bool,
    )
      .._isAvailableOffline = fields[9] as bool
      .._lastDownloadedAt = fields[10] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Tale obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.setting)
      ..writeByte(4)
      ..write(obj.wordCount)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.pages)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj._isAvailableOffline)
      ..writeByte(10)
      ..write(obj._lastDownloadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
