import 'package:get_it/get_it.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale_generation/services/tale_generation_service.dart';

/// Servis bulucu (Service locator) kurulumu.
/// 
/// Bu fonksiyon, uygulama başlatılırken çağrılır ve tüm servisleri kaydeder.
Future<void> setupServiceLocator() async {
  final GetIt locator = GetIt.instance;
  
  // Loglama servisi
  locator.registerSingleton<LoggingService>(LoggingService());
  
  // Ağ servisi
  final networkService = NetworkService();
  await networkService.init();
  locator.registerSingleton<NetworkService>(networkService);
  
  // Görsel önbellekleme servisi
  final imageCacheService = ImageCacheService();
  await imageCacheService.init();
  locator.registerSingleton<ImageCacheService>(imageCacheService);
  
  // API servisleri
  locator.registerSingleton<GeminiApiService>(GeminiApiService());
  locator.registerSingleton<DalleApiService>(DalleApiService());
  
  // Depolama servisi
  final storageService = StorageService();
  await storageService.init();
  locator.registerSingleton<StorageService>(storageService);
  
  // Ses servisi
  final audioService = AudioService();
  await audioService.init();
  locator.registerSingleton<AudioService>(audioService);
  
  // İndirme yöneticisi
  locator.registerSingleton<DownloadManager>(DownloadManager());
  
  // Masal üretim servisi
  locator.registerSingleton<TaleGenerationService>(TaleGenerationService());
}
