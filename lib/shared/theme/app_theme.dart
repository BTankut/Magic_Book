import 'package:flutter/material.dart';

/// Uygulama teması.
/// 
/// Bu sınıf, uygulamanın tema renklerini ve stillerini içerir.
class AppTheme {
  /// Ana renk.
  static const Color primaryColor = Color(0xFF8B4513); // Kahverengi
  
  /// İkincil renk.
  static const Color secondaryColor = Color(0xFFD2B48C); // Tan
  
  /// Arka plan rengi.
  static const Color backgroundColor = Color(0xFFF5F5DC); // Bej
  
  /// Metin rengi.
  static const Color textColor = Color(0xFF3E2723); // Koyu kahverengi
  
  /// Vurgu rengi.
  static const Color accentColor = Color(0xFFCD853F); // Peru
  
  /// Hata rengi.
  static const Color errorColor = Color(0xFFB71C1C); // Koyu kırmızı
  
  /// Başarı rengi.
  static const Color successColor = Color(0xFF2E7D32); // Koyu yeşil
  
  /// Uyarı rengi.
  static const Color warningColor = Color(0xFFF57F17); // Amber
  
  /// Bilgi rengi.
  static const Color infoColor = Color(0xFF0288D1); // Açık mavi
  
  /// Gölge rengi.
  static const Color shadowColor = Color(0x40000000); // Yarı saydam siyah
  
  /// Ana tema verisini döndürür.
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
        headlineSmall: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 18,
          fontFamily: 'Lora',
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'Lora',
        ),
        bodySmall: TextStyle(
          color: textColor,
          fontSize: 14,
          fontFamily: 'Lora',
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: errorColor,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: 16,
        ),
      ),
      cardTheme: CardTheme(
        color: backgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: shadowColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: secondaryColor,
        linearTrackColor: secondaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: secondaryColor,
        thickness: 1,
        space: 16,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
