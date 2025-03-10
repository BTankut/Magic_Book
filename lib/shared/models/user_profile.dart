import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_profile.g.dart';

/// Cinsiyet enum'u.
@HiveType(typeId: 3)
enum Gender {
  @HiveField(0)
  male,
  
  @HiveField(1)
  female,
  
  @HiveField(2)
  other,
}

/// Saç rengi enum'u.
@HiveType(typeId: 4)
enum HairColor {
  @HiveField(0)
  black,
  
  @HiveField(1)
  brown,
  
  @HiveField(2)
  blonde,
  
  @HiveField(3)
  red,
  
  @HiveField(4)
  gray,
  
  @HiveField(5)
  white,
  
  @HiveField(6)
  other,
}

/// Saç tipi enum'u.
@HiveType(typeId: 5)
enum HairType {
  @HiveField(0)
  straight,
  
  @HiveField(1)
  wavy,
  
  @HiveField(2)
  curly,
  
  @HiveField(3)
  coily,
  
  @HiveField(4)
  bald,
}

/// Ten rengi enum'u.
@HiveType(typeId: 6)
enum SkinTone {
  @HiveField(0)
  veryLight,
  
  @HiveField(1)
  light,
  
  @HiveField(2)
  medium,
  
  @HiveField(3)
  tan,
  
  @HiveField(4)
  dark,
  
  @HiveField(5)
  veryDark,
}

/// Kullanıcı profili modeli.
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int age;
  
  @HiveField(3)
  Gender gender;
  
  @HiveField(4)
  HairColor hairColor;
  
  @HiveField(5)
  HairType hairType;
  
  @HiveField(6)
  SkinTone skinTone;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;
  
  /// Yeni bir kullanıcı profili oluşturur.
  UserProfile({
    String? id,
    required this.name,
    required this.age,
    required this.gender,
    required this.hairColor,
    required this.hairType,
    required this.skinTone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
  
  /// Kullanıcı profilini günceller.
  void update({
    String? name,
    int? age,
    Gender? gender,
    HairColor? hairColor,
    HairType? hairType,
    SkinTone? skinTone,
  }) {
    if (name != null) this.name = name;
    if (age != null) this.age = age;
    if (gender != null) this.gender = gender;
    if (hairColor != null) this.hairColor = hairColor;
    if (hairType != null) this.hairType = hairType;
    if (skinTone != null) this.skinTone = skinTone;
    updatedAt = DateTime.now();
  }
  
  /// Kullanıcı profilini kopyalar.
  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    Gender? gender,
    HairColor? hairColor,
    HairType? hairType,
    SkinTone? skinTone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hairColor: hairColor ?? this.hairColor,
      hairType: hairType ?? this.hairType,
      skinTone: skinTone ?? this.skinTone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Cinsiyet enum değerini metne dönüştürür.
  String get genderText {
    switch (gender) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kız';
      case Gender.other:
        return 'Diğer';
    }
  }
  
  /// Saç rengi enum değerini metne dönüştürür.
  String get hairColorText {
    switch (hairColor) {
      case HairColor.black:
        return 'Siyah';
      case HairColor.brown:
        return 'Kahverengi';
      case HairColor.blonde:
        return 'Sarı';
      case HairColor.red:
        return 'Kızıl';
      case HairColor.gray:
        return 'Gri';
      case HairColor.white:
        return 'Beyaz';
      case HairColor.other:
        return 'Diğer';
    }
  }
  
  /// Saç tipi enum değerini metne dönüştürür.
  String get hairTypeText {
    switch (hairType) {
      case HairType.straight:
        return 'Düz';
      case HairType.wavy:
        return 'Dalgalı';
      case HairType.curly:
        return 'Kıvırcık';
      case HairType.coily:
        return 'Sıkı Kıvırcık';
      case HairType.bald:
        return 'Kel';
    }
  }
  
  /// Ten rengi enum değerini metne dönüştürür.
  String get skinToneText {
    switch (skinTone) {
      case SkinTone.veryLight:
        return 'Çok Açık';
      case SkinTone.light:
        return 'Açık';
      case SkinTone.medium:
        return 'Orta';
      case SkinTone.tan:
        return 'Bronz';
      case SkinTone.dark:
        return 'Koyu';
      case SkinTone.veryDark:
        return 'Çok Koyu';
    }
  }
  
  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, gender: $genderText, hairColor: $hairColorText, hairType: $hairTypeText, skinTone: $skinToneText)';
  }
}

/// Hive adaptörlerini oluşturmak için komut:
/// flutter packages pub run build_runner build
