import 'package:flutter_test/flutter_test.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'tale_integration_test.mocks.dart';

@GenerateMocks([
  http.Client,
  LoggingService,
  NetworkService,
  StorageService,
  AudioService,
])
void main() {
  late MockClient mockClient;
  late MockLoggingService mockLoggingService;
  late MockNetworkService mockNetworkService;
  late MockStorageService mockStorageService;
  late MockAudioService mockAudioService;
  late GeminiApiService geminiApiService;
  late DalleApiService dalleApiService;

  setUp(() {
    mockClient = MockClient();
    mockLoggingService = MockLoggingService();
    mockNetworkService = MockNetworkService();
    mockStorageService = MockStorageService();
    mockAudioService = MockAudioService();

    // API servislerini oluştur
    geminiApiService = GeminiApiService.withDependencies(
      mockLoggingService,
      'test_api_key',
      'https://test-api-url.com',
      mockClient,
    );

    dalleApiService = DalleApiService.withDependencies(
      mockLoggingService,
      'test_api_key',
      'https://test-api-url.com',
      mockClient,
    );

    // GetIt'i yapılandır
    getIt.registerSingleton<LoggingService>(mockLoggingService);
    getIt.registerSingleton<NetworkService>(mockNetworkService);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<GeminiApiService>(geminiApiService);
    getIt.registerSingleton<DalleApiService>(dalleApiService);
    getIt.registerSingleton<AudioService>(mockAudioService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('Tale Entegrasyon Testleri', () {
    test('Masal oluşturma ve sayfa ekleme', () {
      // Masal oluştur
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
      );

      // Sayfa oluştur
      final page = TalePage(
        pageNumber: 1,
        content: 'Bu bir test sayfasıdır.',
        imageBase64: 'base64_encoded_image',
        audioPath: 'audio/path.mp3',
      );

      // Masala sayfa ekle
      tale.addPage(page);

      // Doğrulama
      expect(tale.pages.length, 1);
      expect(tale.pages.first.pageNumber, 1);
      expect(tale.pages.first.content, 'Bu bir test sayfasıdır.');
      expect(tale.title, 'Test Masalı');
      expect(tale.theme, 'Macera');
      expect(tale.setting, 'Orman');
      expect(tale.wordCount, 100);
      expect(tale.userId, 'user123');
    });

    test('Masal favori durumu değiştirme', () {
      // Masal oluştur
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
        isFavorite: false,
      );

      // Favori durumunu değiştir
      final updatedTale = tale.copyWithFavorite(true);

      // Doğrulama
      expect(tale.isFavorite, false);
      expect(updatedTale.isFavorite, true);
      expect(updatedTale.title, tale.title);
      expect(updatedTale.id, tale.id);
    });

    test('Masalın tamamen indirilip indirilmediğini kontrol etme', () {
      // Sayfa oluştur
      final page1 = TalePage(
        pageNumber: 1,
        content: 'Sayfa 1',
        imageBase64: 'base64_image',
        audioPath: 'audio/path1.mp3',
      );

      final page2 = TalePage(
        pageNumber: 2,
        content: 'Sayfa 2',
        imageBase64: 'base64_image',
        audioPath: null, // Ses dosyası indirilmemiş
      );

      // Tüm sayfaları indirilmiş masal
      final completelyDownloadedTale = Tale(
        title: 'Tam İndirilmiş Masal',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page1],
      );

      // Bazı sayfaları indirilmemiş masal
      final partiallyDownloadedTale = Tale(
        title: 'Kısmen İndirilmiş Masal',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page1, page2],
      );

      // Doğrulama
      expect(completelyDownloadedTale.isFullyDownloaded, true);
      expect(partiallyDownloadedTale.isFullyDownloaded, false);
    });

    test('Masal JSON dönüşümü', () {
      // Sayfa oluştur
      final page = TalePage(
        pageNumber: 1,
        content: 'Bu bir test sayfasıdır.',
        imageBase64: 'base64_encoded_image',
        audioPath: 'audio/path.mp3',
      );

      // Masal oluştur
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page],
        isFavorite: true,
      );

      // JSON'a dönüştür
      final json = tale.toJson();

      // JSON'dan oluştur
      final fromJson = Tale.fromJson(json);

      // Doğrulama
      expect(fromJson.title, 'Test Masalı');
      expect(fromJson.theme, 'Macera');
      expect(fromJson.setting, 'Orman');
      expect(fromJson.wordCount, 100);
      expect(fromJson.userId, 'user123');
      expect(fromJson.isFavorite, true);
      expect(fromJson.pages.length, 1);
      expect(fromJson.pages.first.pageNumber, 1);
      expect(fromJson.pages.first.content, 'Bu bir test sayfasıdır.');
      expect(fromJson.pages.first.imageBase64, 'base64_encoded_image');
      expect(fromJson.pages.first.audioPath, 'audio/path.mp3');
    });
  });
}
