// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String?,
      name: fields[1] as String,
      age: fields[2] as int,
      gender: fields[3] as Gender,
      hairColor: fields[4] as HairColor,
      hairType: fields[5] as HairType,
      skinTone: fields[6] as SkinTone,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.hairColor)
      ..writeByte(5)
      ..write(obj.hairType)
      ..writeByte(6)
      ..write(obj.skinTone)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 3;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
      case Gender.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HairColorAdapter extends TypeAdapter<HairColor> {
  @override
  final int typeId = 4;

  @override
  HairColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HairColor.black;
      case 1:
        return HairColor.brown;
      case 2:
        return HairColor.blonde;
      case 3:
        return HairColor.red;
      case 4:
        return HairColor.gray;
      case 5:
        return HairColor.white;
      case 6:
        return HairColor.other;
      default:
        return HairColor.black;
    }
  }

  @override
  void write(BinaryWriter writer, HairColor obj) {
    switch (obj) {
      case HairColor.black:
        writer.writeByte(0);
        break;
      case HairColor.brown:
        writer.writeByte(1);
        break;
      case HairColor.blonde:
        writer.writeByte(2);
        break;
      case HairColor.red:
        writer.writeByte(3);
        break;
      case HairColor.gray:
        writer.writeByte(4);
        break;
      case HairColor.white:
        writer.writeByte(5);
        break;
      case HairColor.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HairColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HairTypeAdapter extends TypeAdapter<HairType> {
  @override
  final int typeId = 5;

  @override
  HairType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HairType.straight;
      case 1:
        return HairType.wavy;
      case 2:
        return HairType.curly;
      case 3:
        return HairType.coily;
      case 4:
        return HairType.bald;
      default:
        return HairType.straight;
    }
  }

  @override
  void write(BinaryWriter writer, HairType obj) {
    switch (obj) {
      case HairType.straight:
        writer.writeByte(0);
        break;
      case HairType.wavy:
        writer.writeByte(1);
        break;
      case HairType.curly:
        writer.writeByte(2);
        break;
      case HairType.coily:
        writer.writeByte(3);
        break;
      case HairType.bald:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HairTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkinToneAdapter extends TypeAdapter<SkinTone> {
  @override
  final int typeId = 6;

  @override
  SkinTone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkinTone.veryLight;
      case 1:
        return SkinTone.light;
      case 2:
        return SkinTone.medium;
      case 3:
        return SkinTone.tan;
      case 4:
        return SkinTone.dark;
      case 5:
        return SkinTone.veryDark;
      default:
        return SkinTone.veryLight;
    }
  }

  @override
  void write(BinaryWriter writer, SkinTone obj) {
    switch (obj) {
      case SkinTone.veryLight:
        writer.writeByte(0);
        break;
      case SkinTone.light:
        writer.writeByte(1);
        break;
      case SkinTone.medium:
        writer.writeByte(2);
        break;
      case SkinTone.tan:
        writer.writeByte(3);
        break;
      case SkinTone.dark:
        writer.writeByte(4);
        break;
      case SkinTone.veryDark:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkinToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
