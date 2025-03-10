import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:magic_book/features/onboarding/screens/welcome_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:provider/provider.dart';

/// Ana uygulama sınıfı.
/// 
/// Bu sınıf, uygulamanın temel yapılandırmasını ve tema ayarlarını içerir.
class MagicBookApp extends StatelessWidget {
  const MagicBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Uygulama yönünü dikey olarak sabitle
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return MultiProvider(
      providers: [
        // İndirme yöneticisi
        ChangeNotifierProvider<DownloadManager>(
          create: (_) => getIt<DownloadManager>(),
        ),
      ],
      child: MaterialApp(
        title: 'Magic Book',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Sistem temasını kullan
        home: const WelcomeScreen(), // Başlangıç ekranı
      ),
    );
  }
}
