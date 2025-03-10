/// Cinsiyet enum'u.
enum Gender {
  /// Erkek
  male,
  
  /// Kız
  female,
  
  /// Belirtilmemiş
  unspecified,
}

/// Gender için uzantı metotları.
extension GenderExtension on Gender {
  /// Cinsiyet adını döndürür.
  String get name {
    switch (this) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kız';
      case Gender.unspecified:
        return 'Belirtilmemiş';
    }
  }
}
