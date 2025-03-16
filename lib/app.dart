import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:magic_book/features/onboarding/screens/welcome_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/providers/theme_provider.dart';
import 'package:provider/provider.dart' as provider;

/// Ana uygulama sınıfı.
/// 
/// Bu sınıf, uygulamanın temel yapılandırmasını ve tema ayarlarını içerir.
class MagicBookApp extends ConsumerWidget {
  const MagicBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // iPad için yatay mod desteği eklendi
    // Yön kısıtlaması kaldırıldı
    
    // Tema değerleri
    final themeType = ref.watch(themeTypeProvider);
    final useSystemTheme = ref.watch(useSystemThemeProvider);
    
    // Tema seçimi
    final lightTheme = AppTheme.getThemeData(themeType, isDark: false);
    final darkTheme = AppTheme.getThemeData(themeType, isDark: true);
    final themeMode = useSystemTheme ? ThemeMode.system : ThemeMode.light;
    
    return provider.ChangeNotifierProvider<DownloadManager>(
      create: (_) => getIt<DownloadManager>(),
      child: MaterialApp(
        title: 'Magic Book',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: const WelcomeScreen(), // Başlangıç ekranı
        builder: (context, child) {
          // Cihaz tipine göre tema ayarlarını uygula
          final mediaQueryData = MediaQuery.of(context);
          
          // Metin ölçeklendirmeyi sınırla (çok büyük yazı boyutları için)
          final constrainedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(0.8, 1.4);
          
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaleFactor: constrainedTextScaleFactor,
            ),
            child: Builder(
              builder: (context) {
                // Cihaz tipine göre tema ayarlarını uygula
                final theme = Theme.of(context);
                final adjustedTheme = AppTheme.applyDeviceSpecificSettings(context, theme);
                
                return Theme(
                  data: adjustedTheme,
                  child: child!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
