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
    // Uygulama yönünü dikey olarak sabitle
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
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
      ),
    );
  }
}
