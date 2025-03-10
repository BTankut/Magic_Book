import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale_viewer/screens/tale_viewer_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ui_integration_test.mocks.dart';

@GenerateMocks([
  LoggingService,
  NetworkService,
  StorageService,
  GeminiApiService,
  DalleApiService,
  AudioService,
])
void main() {
  late MockLoggingService mockLoggingService;
  late MockNetworkService mockNetworkService;
  late MockStorageService mockStorageService;
  late MockGeminiApiService mockGeminiApiService;
  late MockDalleApiService mockDalleApiService;
  late MockAudioService mockAudioService;

  setUp(() {
    mockLoggingService = MockLoggingService();
    mockNetworkService = MockNetworkService();
    mockStorageService = MockStorageService();
    mockGeminiApiService = MockGeminiApiService();
    mockDalleApiService = MockDalleApiService();
    mockAudioService = MockAudioService();

    // GetIt'i yapılandır
    getIt.registerSingleton<LoggingService>(mockLoggingService);
    getIt.registerSingleton<NetworkService>(mockNetworkService);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<GeminiApiService>(mockGeminiApiService);
    getIt.registerSingleton<DalleApiService>(mockDalleApiService);
    getIt.registerSingleton<AudioService>(mockAudioService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('UI Entegrasyon Testleri', () {
    testWidgets('AntiqueButton widget testi', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      // Widget'ı oluştur
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AntiqueButton(
                text: 'Test Butonu',
                onPressed: () {
                  buttonPressed = true;
                },
                icon: Icons.book,
              ),
            ),
          ),
        ),
      );
      
      // Butonu bul
      final buttonFinder = find.text('Test Butonu');
      expect(buttonFinder, findsOneWidget);
      
      // İkonu bul
      final iconFinder = find.byIcon(Icons.book);
      expect(iconFinder, findsOneWidget);
      
      // Butona tıkla
      await tester.tap(buttonFinder);
      await tester.pump();
      
      // Doğrulama
      expect(buttonPressed, true);
    });

    testWidgets('TaleViewerScreen favori butonu testi', (WidgetTester tester) async {
      // Test verilerini hazırla
      final page = TalePage(
        pageNumber: 1,
        content: 'Test sayfası içeriği',
        imageBase64: 'base64_encoded_image',
        audioPath: 'audio/path.mp3',
      );

      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page],
        isFavorite: false,
      );
      
      // Mock davranışları
      when(mockNetworkService.isConnected).thenReturn(true);
      when(mockAudioService.isPlaying).thenReturn(false);
      when(mockAudioService.speak(any)).thenAnswer((_) async {});
      when(mockAudioService.stop()).thenAnswer((_) async {});
      when(mockStorageService.updateTale(any)).thenAnswer((_) async {});
      
      // Widget'ı oluştur
      await tester.pumpWidget(
        MaterialApp(
          home: TaleViewerScreen(tale: tale),
        ),
      );
      
      // AppBar'ı bul
      expect(find.text('Test Masalı'), findsOneWidget);
      
      // Favori butonunu bul
      final favoriteButtonFinder = find.byIcon(Icons.favorite_border);
      expect(favoriteButtonFinder, findsOneWidget);
      
      // Favori butonuna tıkla
      await tester.tap(favoriteButtonFinder);
      await tester.pumpAndSettle();
      
      // Doğrulama - updateTale metodu çağrılmalı
      verify(mockStorageService.updateTale(any)).called(1);
    });

    testWidgets('TaleViewerScreen ses kontrolleri testi', (WidgetTester tester) async {
      // Test verilerini hazırla
      final page = TalePage(
        pageNumber: 1,
        content: 'Test sayfası içeriği',
        imageBase64: 'base64_encoded_image',
        audioPath: 'audio/path.mp3',
      );

      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page],
        isFavorite: false,
      );
      
      // Mock davranışları
      when(mockNetworkService.isConnected).thenReturn(true);
      when(mockAudioService.isPlaying).thenReturn(false);
      when(mockAudioService.speak(any)).thenAnswer((_) async {});
      when(mockAudioService.stop()).thenAnswer((_) async {});
      
      // Widget'ı oluştur
      await tester.pumpWidget(
        MaterialApp(
          home: TaleViewerScreen(tale: tale),
        ),
      );
      
      // Ses butonunu bul
      final audioButtonFinder = find.byIcon(Icons.volume_up);
      expect(audioButtonFinder, findsOneWidget);
      
      // Ses butonuna tıkla
      await tester.tap(audioButtonFinder);
      await tester.pumpAndSettle();
      
      // Doğrulama - speak metodu çağrılmalı
      verify(mockAudioService.speak(any)).called(1);
      
      // Ses durumunu değiştir
      when(mockAudioService.isPlaying).thenReturn(true);
      
      // Widget'ı yenile
      await tester.pumpAndSettle();
      
      // Ses butonuna tekrar tıkla
      await tester.tap(audioButtonFinder);
      await tester.pumpAndSettle();
      
      // Doğrulama - stop metodu çağrılmalı
      verify(mockAudioService.stop()).called(1);
    });

    testWidgets('TaleViewerScreen sayfa değiştirme testi', (WidgetTester tester) async {
      // Test verilerini hazırla
      final page1 = TalePage(
        pageNumber: 1,
        content: 'Sayfa 1 içeriği',
        imageBase64: 'base64_encoded_image_1',
        audioPath: 'audio/path1.mp3',
      );
      
      final page2 = TalePage(
        pageNumber: 2,
        content: 'Sayfa 2 içeriği',
        imageBase64: 'base64_encoded_image_2',
        audioPath: 'audio/path2.mp3',
      );

      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page1, page2],
        isFavorite: false,
      );
      
      // Mock davranışları
      when(mockNetworkService.isConnected).thenReturn(true);
      when(mockAudioService.isPlaying).thenReturn(false);
      when(mockAudioService.stop()).thenAnswer((_) async {});
      
      // Widget'ı oluştur
      await tester.pumpWidget(
        MaterialApp(
          home: TaleViewerScreen(tale: tale),
        ),
      );
      
      // İlk sayfayı kontrol et
      expect(find.text('Sayfa 1 içeriği'), findsOneWidget);
      
      // Sonraki sayfa butonunu bul
      final nextPageButtonFinder = find.byIcon(Icons.arrow_forward);
      expect(nextPageButtonFinder, findsOneWidget);
      
      // Sonraki sayfaya geç
      await tester.tap(nextPageButtonFinder);
      await tester.pumpAndSettle();
      
      // İkinci sayfayı kontrol et
      expect(find.text('Sayfa 2 içeriği'), findsOneWidget);
      
      // Önceki sayfa butonunu bul
      final previousPageButtonFinder = find.byIcon(Icons.arrow_back);
      expect(previousPageButtonFinder, findsOneWidget);
      
      // Önceki sayfaya geç
      await tester.tap(previousPageButtonFinder);
      await tester.pumpAndSettle();
      
      // Tekrar ilk sayfayı kontrol et
      expect(find.text('Sayfa 1 içeriği'), findsOneWidget);
    });
  });
}
