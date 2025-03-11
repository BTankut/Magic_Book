import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seçilen tema türünü tutan Provider
final themeTypeProvider = StateProvider<int>((ref) => AppTheme.classic);

/// Sistem teması kullanımını tutan Provider
final useSystemThemeProvider = StateProvider<bool>((ref) => true);

/// Aktif tema için aydınlık Provider
final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(themeTypeProvider);
  return AppTheme.getThemeData(themeType, isDark: false);
});

/// Aktif tema için karanlık Provider
final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(themeTypeProvider);
  return AppTheme.getThemeData(themeType, isDark: true);
});

/// Tema modunu getirmek için Provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final useSystemTheme = ref.watch(useSystemThemeProvider);
  return useSystemTheme ? ThemeMode.system : ThemeMode.light;
});

/// Tema türünü değiştirmek için fonksiyon
Future<void> changeThemeType(WidgetRef ref, int themeType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeType', themeType);
  ref.read(themeTypeProvider.notifier).state = themeType;
}

/// Sistem teması kullanımını değiştirmek için fonksiyon
Future<void> toggleUseSystemTheme(WidgetRef ref, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('useSystemTheme', value);
  ref.read(useSystemThemeProvider.notifier).state = value;
}