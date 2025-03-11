import 'package:flutter/foundation.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema yönetici sınıfı.
/// 
/// Bu sınıf, uygulamanın temasını yönetir ve değiştirir.
class AppThemeManager with ChangeNotifier {
  /// Seçili tema türü
  int _selectedTheme = AppTheme.classic;
  
  /// Sistem teması kullanılsın mı?
  bool _useSystemTheme = true;
  
  /// Seçili tema türünü döndürür
  int get selectedTheme => _selectedTheme;
  
  /// Sistem teması kullanılıp kullanılmadığını döndürür
  bool get useSystemTheme => _useSystemTheme;
  
  /// Tema adını döndürür
  String get themeName => AppTheme.themeNames[_selectedTheme] ?? "Klasik";
  
  /// Tema yöneticisini başlatır
  Future<void> initialize() async {
    await _loadThemePreference();
  }
  
  /// Tema tercihini yükler
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedTheme = prefs.getInt('selectedTheme') ?? AppTheme.classic;
      _useSystemTheme = prefs.getBool('useSystemTheme') ?? true;
      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan değerleri kullan
      _selectedTheme = AppTheme.classic;
      _useSystemTheme = true;
    }
  }
  
  /// Tema tercihini kaydeder
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedTheme', _selectedTheme);
      await prefs.setBool('useSystemTheme', _useSystemTheme);
    } catch (e) {
      // Kaydetme hatalarını yok say
    }
  }
  
  /// Tema türünü değiştirir
  void setTheme(int themeType) {
    if (_selectedTheme != themeType) {
      _selectedTheme = themeType;
      _saveThemePreference();
      notifyListeners();
    }
  }
  
  /// Sistem teması kullanımını değiştirir
  void setUseSystemTheme(bool value) {
    if (_useSystemTheme != value) {
      _useSystemTheme = value;
      _saveThemePreference();
      notifyListeners();
    }
  }
}