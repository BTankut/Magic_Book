import 'package:flutter/material.dart';

/// Masal konusu.
enum TaleTheme {
  /// Macera konusu.
  adventure,
  
  /// Fantastik konu.
  fantasy,
  
  /// Arkadaşlık konusu.
  friendship,
  
  /// Doğa konusu.
  nature,
  
  /// Uzay konusu.
  space,
  
  /// Hayvanlar konusu.
  animals,
  
  /// Sihir konusu.
  magic,
  
  /// Kahramanlar konusu.
  heroes,
}

/// Masal ortamı.
enum TaleSetting {
  /// Orman ortamı.
  forest,
  
  /// Şato ortamı.
  castle,
  
  /// Uzay ortamı.
  space,
  
  /// Okyanus ortamı.
  ocean,
  
  /// Dağ ortamı.
  mountain,
  
  /// Şehir ortamı.
  city,
  
  /// Köy ortamı.
  village,
  
  /// Ada ortamı.
  island,
  
  /// Çöl ortamı.
  desert,
  
  /// Yağmur ormanı ortamı.
  rainforest,
}

/// Tema adını döndürür.
String getTaleThemeName(TaleTheme theme) {
  switch (theme) {
    case TaleTheme.adventure:
      return 'Macera';
    case TaleTheme.fantasy:
      return 'Fantastik';
    case TaleTheme.friendship:
      return 'Arkadaşlık';
    case TaleTheme.nature:
      return 'Doğa';
    case TaleTheme.space:
      return 'Uzay';
    case TaleTheme.animals:
      return 'Hayvanlar';
    case TaleTheme.magic:
      return 'Sihir';
    case TaleTheme.heroes:
      return 'Kahramanlar';
  }
}

/// Ortam adını döndürür.
String getTaleSettingName(TaleSetting setting) {
  switch (setting) {
    case TaleSetting.forest:
      return 'Orman';
    case TaleSetting.castle:
      return 'Şato';
    case TaleSetting.space:
      return 'Uzay';
    case TaleSetting.ocean:
      return 'Okyanus';
    case TaleSetting.mountain:
      return 'Dağ';
    case TaleSetting.city:
      return 'Şehir';
    case TaleSetting.village:
      return 'Köy';
    case TaleSetting.island:
      return 'Ada';
    case TaleSetting.desert:
      return 'Çöl';
    case TaleSetting.rainforest:
      return 'Yağmur Ormanı';
  }
}

/// Tema renklerini döndürür.
Color getTaleThemeColor(TaleTheme theme) {
  switch (theme) {
    case TaleTheme.adventure:
      return Colors.orange;
    case TaleTheme.fantasy:
      return Colors.purple;
    case TaleTheme.friendship:
      return Colors.pink;
    case TaleTheme.nature:
      return Colors.green;
    case TaleTheme.space:
      return Colors.blue;
    case TaleTheme.animals:
      return Colors.brown;
    case TaleTheme.magic:
      return Colors.indigo;
    case TaleTheme.heroes:
      return Colors.red;
  }
}

/// Tema ikonlarını döndürür.
IconData getTaleThemeIcon(TaleTheme theme) {
  switch (theme) {
    case TaleTheme.adventure:
      return Icons.explore;
    case TaleTheme.fantasy:
      return Icons.auto_awesome;
    case TaleTheme.friendship:
      return Icons.people;
    case TaleTheme.nature:
      return Icons.nature;
    case TaleTheme.space:
      return Icons.rocket_launch;
    case TaleTheme.animals:
      return Icons.pets;
    case TaleTheme.magic:
      return Icons.auto_fix_high;
    case TaleTheme.heroes:
      return Icons.shield;
  }
}

/// Ortam ikonlarını döndürür.
IconData getTaleSettingIcon(TaleSetting setting) {
  switch (setting) {
    case TaleSetting.forest:
      return Icons.forest;
    case TaleSetting.castle:
      return Icons.castle;
    case TaleSetting.space:
      return Icons.stars;
    case TaleSetting.ocean:
      return Icons.water;
    case TaleSetting.mountain:
      return Icons.landscape;
    case TaleSetting.city:
      return Icons.location_city;
    case TaleSetting.village:
      return Icons.home;
    case TaleSetting.island:
      return Icons.terrain;
    case TaleSetting.desert:
      return Icons.wb_sunny;
    case TaleSetting.rainforest:
      return Icons.park;
  }
}
