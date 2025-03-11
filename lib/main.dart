import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magic_book/app.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/service_locator.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/models/user_profile.dart';
// 'theme_provider.dart' başka bir yerde kullanılıyor, ana kodda değil
// import 'package:magic_book/shared/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servis bulucu (Service locator) için global nesne
final GetIt getIt = GetIt.instance;

/// Uygulama başlangıç noktası
void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle
  await dotenv.load(fileName: '.env');
  
  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Loglama servisini başlat
  final loggingService = LoggingService();
  
  // Hive veritabanını başlat
  await Hive.initFlutter();
  
  // Hive adaptörlerini kaydet
  try {
    // Önce bağımlı olunan sınıfların adaptörlerini kaydet
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GenderAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(HairColorAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(HairTypeAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SkinToneAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TalePageAdapter());
    
    // Sonra bağımlı olan sınıfların adaptörlerini kaydet
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaleAdapter());
    
    loggingService.i('Hive adaptörleri başarıyla kaydedildi');
  } catch (e) {
    loggingService.w('Hive adaptörleri kaydedilirken bir sorun oluştu: $e');
  }
  
  // Servisleri başlat (LoggingService service_locator içinde kaydedilecek)
  await setupServiceLocator();
  
  // Tema tercihi yükleniyor
  final prefs = await SharedPreferences.getInstance();
  final themeType = prefs.getInt('themeType') ?? AppTheme.classic;
  final useSystemTheme = prefs.getBool('useSystemTheme') ?? true;
  
  // Uygulamayı başlat
  runApp(
    // Riverpod ile durum yönetimi için ProviderScope ekle
    const ProviderScope(
      child: MagicBookApp(),
    ),
  );
  
  // Tema değerlerini ayarla (bu şekilde initial değerleri yüklüyoruz)
  getIt.get<LoggingService>().i('Tema değerleri yüklendi: themeType=$themeType, useSystemTheme=$useSystemTheme');
  
  // Bu değerler daha sonra ilk build sırasında kullanılacak
}
