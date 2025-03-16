import 'package:flutter/material.dart';
import 'package:magic_book/shared/utils/device_utils.dart';

/// Uygulama teması.
/// 
/// Bu sınıf, uygulamanın tema ayarlarını içerir.
class AppTheme {
  // Tema seçicisi için sabitler - camelCase kullanılmalı
  static const int classic = 0;
  static const int fantasy = 1;
  static const int ocean = 2;
  static const int space = 3;
  
  // Tema adları
  static const Map<int, String> themeNames = {
    classic: "Klasik",
    fantasy: "Fantastik",
    ocean: "Deniz",
    space: "Uzay",
  };
  
  // Varsayılan (Klasik) tema - Kahverengi tonları
  static const Color primaryColor = Color(0xFF61472C); // Daha koyu kahverengi (ana renk)
  static const Color primaryLightColor = Color(0xFF8B6E4D); // Orta kahverengi
  static const Color secondaryColor = Color(0xFFAB8F6D); // Açık kahverengi
  static const Color accentColor = Color(0xFF3A506B); // Koyu mavi aksanlar için
  static const Color backgroundColor = Color(0xFFEFE6D9); // Açık krem arka plan
  static const Color cardColor = Color(0xFFF8F2E9); // Kart arka planı için daha açık ton
  static const Color textColor = Color(0xFF2E2418); // Koyu kahverengi metin
  static const Color textLightColor = Color(0xFFF8F2E9); // Açık metin rengi
  static const Color errorColor = Color(0xFFD64933); // Kırmızı (hata rengi)
  
  // Fantastik tema - Mor ve mavi tonları
  static const Color fantasyPrimaryColor = Color(0xFF6A0DAD); // Mor (ana renk)
  static const Color fantasyPrimaryLightColor = Color(0xFF9370DB); // Orta mor
  static const Color fantasySecondaryColor = Color(0xFFB19CD9); // Açık lavanta
  static const Color fantasyAccentColor = Color(0xFFE6B422); // Altın rengi aksanlar için
  static const Color fantasyBackgroundColor = Color(0xFFF4EFFC); // Açık lavanta arka plan
  static const Color fantasyCardColor = Color(0xFFFAF8FF); // Kart arka planı için daha açık ton
  static const Color fantasyTextColor = Color(0xFF2D0C57); // Koyu mor metin
  static const Color fantasyTextLightColor = Color(0xFFF8F6FF); // Açık metin rengi
  static const Color fantasyErrorColor = Color(0xFFD32F2F); // Kırmızı (hata rengi)
  
  // Deniz teması - Mavi tonları
  static const Color oceanPrimaryColor = Color(0xFF1A5F7A); // Deniz mavisi (ana renk)
  static const Color oceanPrimaryLightColor = Color(0xFF3792CB); // Orta mavi
  static const Color oceanSecondaryColor = Color(0xFF89CFF0); // Açık mavi
  static const Color oceanAccentColor = Color(0xFFFF9A8B); // Mercan rengi aksanlar için
  static const Color oceanBackgroundColor = Color(0xFFE6F2F5); // Açık mavi arka plan
  static const Color oceanCardColor = Color(0xFFF1FBFF); // Kart arka planı için daha açık ton
  static const Color oceanTextColor = Color(0xFF0A3143); // Koyu lacivert metin
  static const Color oceanTextLightColor = Color(0xFFF0F8FF); // Açık metin rengi
  static const Color oceanErrorColor = Color(0xFFE74C3C); // Kırmızı (hata rengi)
  
  // Uzay teması - Koyu tonlar
  static const Color spacePrimaryColor = Color(0xFF3F0071); // Koyu mor (ana renk)
  static const Color spacePrimaryLightColor = Color(0xFF7B2CBF); // Orta mor
  static const Color spaceSecondaryColor = Color(0xFF9D4EDD); // Açık mor
  static const Color spaceAccentColor = Color(0xFF10DAC0); // Turkuaz aksanlar için
  static const Color spaceBackgroundColor = Color(0xFF121212); // Koyu siyah arka plan
  static const Color spaceCardColor = Color(0xFF1E1E1E); // Kart arka planı için daha açık ton
  static const Color spaceTextColor = Color(0xFFE6E6E6); // Beyaz metin
  static const Color spaceTextLightColor = Color(0xFFFFFFFF); // Açık metin rengi
  static const Color spaceErrorColor = Color(0xFFFF5252); // Kırmızı (hata rengi)
  
  // Yazı tipleri
  static const String primaryFontFamily = 'Montserrat';
  static const String secondaryFontFamily = 'Merriweather';
  
  // Arka plan dekorasyonu
  static BoxDecoration get paperBackgroundDecoration {
    return const BoxDecoration(
      // Daha koyu arka plan rengi (krem yerine hafif kahverengi)
      color: Color(0xFFE9D9C4),
    );
  }
  
  // Tema verileri getter metodu
  static ThemeData getThemeData(int themeType, {bool isDark = false}) {
    switch(themeType) {
      case fantasy:
        return isDark ? _getFantasyDarkTheme() : _getFantasyLightTheme();
      case ocean:
        return isDark ? _getOceanDarkTheme() : _getOceanLightTheme();
      case space:
        return isDark ? _getSpaceDarkTheme() : _getSpaceLightTheme();
      case classic:
      default:
        return isDark ? darkTheme : lightTheme;
    }
  }
  
  // Işık teması - Klasik
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: textColor,
      onBackground: textColor,
      surface: Colors.white,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  // Karanlık tema
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: const Color(0xFF1E1E1E),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      surface: const Color(0xFF2C2C2C),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: secondaryFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white54,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white54;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white54;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.white38;
      }),
    ),
  );
  
  // Fantastik tema - Açık
  static ThemeData _getFantasyLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: fantasyPrimaryColor,
        secondary: fantasySecondaryColor,
        tertiary: fantasyAccentColor,
        background: fantasyBackgroundColor,
        error: fantasyErrorColor,
        onPrimary: Colors.white,
        onSecondary: fantasyTextColor,
        onBackground: fantasyTextColor,
        surface: fantasyCardColor,
        onSurface: fantasyTextColor,
      ),
      scaffoldBackgroundColor: fantasyBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: fantasyPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: fantasyTextColor,
        ),
        displayMedium: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: fantasyTextColor,
        ),
        displaySmall: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: fantasyTextColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
        titleLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
        titleMedium: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
        titleSmall: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: fantasyTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          color: fantasyTextColor,
        ),
        bodySmall: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 12,
          color: fantasyTextColor,
        ),
        labelLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fantasyTextColor,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: fantasyPrimaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: fantasyPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: fantasyCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  // Fantastik tema - Koyu
  static ThemeData _getFantasyDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: fantasyPrimaryColor,
        secondary: fantasySecondaryColor,
        tertiary: fantasyAccentColor,
        background: Color(0xFF1A0A2E),
        error: fantasyErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: Color(0xFF2D1C45),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF1A0A2E),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: fantasyPrimaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Color(0xFF2D1C45),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  // Deniz tema - Açık
  static ThemeData _getOceanLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: oceanPrimaryColor,
        secondary: oceanSecondaryColor,
        tertiary: oceanAccentColor,
        background: oceanBackgroundColor,
        error: oceanErrorColor,
        onPrimary: Colors.white,
        onSecondary: oceanTextColor,
        onBackground: oceanTextColor,
        surface: oceanCardColor,
        onSurface: oceanTextColor,
      ),
      scaffoldBackgroundColor: oceanBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: oceanPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: oceanTextColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: oceanTextColor,
        ),
      ),
      cardTheme: CardTheme(
        color: oceanCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  // Deniz tema - Koyu
  static ThemeData _getOceanDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: oceanPrimaryColor,
        secondary: oceanSecondaryColor,
        tertiary: oceanAccentColor,
        background: Color(0xFF0A2A38),
        error: oceanErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: Color(0xFF103A4C),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF0A2A38),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: oceanPrimaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Color(0xFF103A4C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  // Uzay tema - Açık
  static ThemeData _getSpaceLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: spacePrimaryColor,
        secondary: spaceSecondaryColor,
        tertiary: spaceAccentColor,
        background: Color(0xFFF0EDF5),
        error: spaceErrorColor,
        onPrimary: Colors.white,
        onSecondary: spacePrimaryColor,
        onBackground: spacePrimaryColor,
        surface: Colors.white,
        onSurface: spacePrimaryColor,
      ),
      scaffoldBackgroundColor: Color(0xFFF0EDF5),
      appBarTheme: const AppBarTheme(
        backgroundColor: spacePrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: spacePrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: spacePrimaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: spacePrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  // Uzay tema - Koyu
  static ThemeData _getSpaceDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: spacePrimaryColor,
        secondary: spaceSecondaryColor,
        tertiary: spaceAccentColor,
        background: spaceBackgroundColor,
        error: spaceErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        surface: spaceCardColor,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: spaceBackgroundColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: secondaryFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spacePrimaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: spaceCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  /// Cihaz tipine göre tema ayarlarını uygular
  static ThemeData applyDeviceSpecificSettings(BuildContext context, ThemeData theme) {
    final deviceType = DeviceUtils.getDeviceType(context);
    
    // Tablet (iPad) için özel ayarlar
    if (deviceType == DeviceType.tablet) {
      return theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          displayLarge: theme.textTheme.displayLarge?.copyWith(
            fontSize: 32.0, // iPad için daha büyük başlık
          ),
          displayMedium: theme.textTheme.displayMedium?.copyWith(
            fontSize: 28.0,
          ),
          displaySmall: theme.textTheme.displaySmall?.copyWith(
            fontSize: 24.0,
          ),
          headlineMedium: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22.0,
          ),
          bodyLarge: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 18.0, // iPad için daha büyük metin
          ),
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16.0,
          ),
        ),
        // iPad için daha geniş butonlar
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(120, 48),
          ),
        ),
        // iPad için daha geniş input alanları
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      );
    }
    
    // Diğer cihazlar için orijinal temayı döndür
    return theme;
  }
}
