import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale_viewer/screens/tale_viewer_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';

import 'tale_viewer_integration_test.mocks.dart';

@GenerateMocks([AudioService, LoggingService, StorageService, NetworkService])
void main() {
  late MockAudioService mockAudioService;
  late MockLoggingService mockLogger;
  late MockStorageService mockStorageService;
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockAudioService = MockAudioService();
    mockLogger = MockLoggingService();
    mockStorageService = MockStorageService();
    mockNetworkService = MockNetworkService();

    // GetIt'i yapılandır
    getIt.registerSingleton<AudioService>(mockAudioService);
    getIt.registerSingleton<LoggingService>(mockLogger);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<NetworkService>(mockNetworkService);
  });

  tearDown(() {
    // GetIt'i temizle
    getIt.reset();
  });

  // Test için örnek bir masal oluştur
  Tale createTestTale() {
    return Tale(
      id: 'test_tale_id',
      title: 'Test Masal',
      theme: TaleTheme.fantasy,
      setting: TaleSetting.forest,
      wordCount: 300,
      userProfileId: 'test_user_id',
      isFavorite: false,
      createdAt: DateTime.now(),
      pages: [
        TalePage(
          content: 'Bu bir test masal sayfasıdır. Sayfa 1.',
          imageBase64: base64Encode(Uint8List.fromList([1, 2, 3, 4, 5])),
          audioBase64: null,
        ),
        TalePage(
          content: 'Bu bir test masal sayfasıdır. Sayfa 2.',
          imageBase64: base64Encode(Uint8List.fromList([6, 7, 8, 9, 10])),
          audioBase64: null,
        ),
      ],
    );
  }

  testWidgets('TaleViewerScreen ve AudioService entegrasyonu - sesli anlatım başlatma ve durdurma', (WidgetTester tester) async {
    // Arrange
    final testTale = createTestTale();
    
    // StorageService mock yapılandırması
    when(mockStorageService.getTale('test_tale_id')).thenAnswer((_) => testTale);
    
    // NetworkService mock yapılandırması
    when(mockNetworkService.getCurrentNetworkStatus()).thenAnswer((_) async => NetworkStatus.online);
    when(mockNetworkService.networkStatusStream).thenAnswer((_) => Stream.value(NetworkStatus.online));
    
    // AudioService mock yapılandırması
    when(mockAudioService.speak(any)).thenAnswer((_) async {});
    when(mockAudioService.stop()).thenAnswer((_) async {});
    
    // Act - Widget'ı oluştur
    await tester.pumpWidget(
      MaterialApp(
        home: TaleViewerScreen(taleId: 'test_tale_id'),
      ),
    );
    
    // Yükleme durumunu bekle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Assert - Masal yüklendi mi kontrol et
    expect(find.text('Test Masal'), findsOneWidget);
    expect(find.text('Bu bir test masal sayfasıdır. Sayfa 1.'), findsOneWidget);
    
    // Ses düğmesini bul ve tıkla
    final audioButton = find.byIcon(Icons.volume_up);
    expect(audioButton, findsOneWidget);
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım başlatıldı mı kontrol et
    verify(mockAudioService.speak('Bu bir test masal sayfasıdır. Sayfa 1.')).called(1);
    
    // Ses düğmesini tekrar tıkla (durdurma)
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım durduruldu mu kontrol et
    verify(mockAudioService.stop()).called(1);
  });

  testWidgets('TaleViewerScreen ve AudioService entegrasyonu - sayfa değiştiğinde sesli anlatım', (WidgetTester tester) async {
    // Arrange
    final testTale = createTestTale();
    
    // StorageService mock yapılandırması
    when(mockStorageService.getTale('test_tale_id')).thenAnswer((_) => testTale);
    
    // NetworkService mock yapılandırması
    when(mockNetworkService.getCurrentNetworkStatus()).thenAnswer((_) async => NetworkStatus.online);
    when(mockNetworkService.networkStatusStream).thenAnswer((_) => Stream.value(NetworkStatus.online));
    
    // AudioService mock yapılandırması
    when(mockAudioService.speak(any)).thenAnswer((_) async {});
    when(mockAudioService.stop()).thenAnswer((_) async {});
    
    // Act - Widget'ı oluştur
    await tester.pumpWidget(
      MaterialApp(
        home: TaleViewerScreen(taleId: 'test_tale_id'),
      ),
    );
    
    // Yükleme durumunu bekle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Ses düğmesini tıkla
    final audioButton = find.byIcon(Icons.volume_up);
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım başlatıldı mı kontrol et
    verify(mockAudioService.speak('Bu bir test masal sayfasıdır. Sayfa 1.')).called(1);
    
    // Sonraki sayfa düğmesini bul ve tıkla
    final nextPageButton = find.byIcon(Icons.arrow_forward);
    expect(nextPageButton, findsOneWidget);
    await tester.tap(nextPageButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Animasyon için bekle
    
    // Sayfa değişti mi kontrol et
    expect(find.text('Bu bir test masal sayfasıdır. Sayfa 2.'), findsOneWidget);
    
    // Sesli anlatım durduruldu mu kontrol et
    verify(mockAudioService.stop()).called(1);
    
    // Yeni sayfada sesli anlatımı başlat
    await tester.tap(audioButton);
    await tester.pump();
    
    // Yeni sayfanın sesli anlatımı başlatıldı mı kontrol et
    verify(mockAudioService.speak('Bu bir test masal sayfasıdır. Sayfa 2.')).called(1);
  });

  testWidgets('TaleViewerScreen ve AudioService entegrasyonu - sesli anlatım tamamlanma callback\'i', (WidgetTester tester) async {
    // Arrange
    final testTale = createTestTale();
    
    // StorageService mock yapılandırması
    when(mockStorageService.getTale('test_tale_id')).thenAnswer((_) => testTale);
    
    // NetworkService mock yapılandırması
    when(mockNetworkService.getCurrentNetworkStatus()).thenAnswer((_) async => NetworkStatus.online);
    when(mockNetworkService.networkStatusStream).thenAnswer((_) => Stream.value(NetworkStatus.online));
    
    // AudioService mock yapılandırması
    when(mockAudioService.speak(any)).thenAnswer((_) async {});
    when(mockAudioService.stop()).thenAnswer((_) async {});
    
    // Act - Widget'ı oluştur
    await tester.pumpWidget(
      MaterialApp(
        home: TaleViewerScreen(taleId: 'test_tale_id'),
      ),
    );
    
    // Yükleme durumunu bekle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Ses düğmesini tıkla
    final audioButton = find.byIcon(Icons.volume_up);
    await tester.tap(audioButton);
    await tester.pump();
    
    // onComplete callback'ini yakala
    verify(mockAudioService.speak(any)).called(1);
    
    // onComplete callback'ini çağır
    final capturedOnComplete = verify(mockAudioService.onComplete = captureAny).captured.first as Function?;
    expect(capturedOnComplete, isNotNull);
    
    // Callback'i çağır
    capturedOnComplete!();
    await tester.pump();
    
    // Sesli anlatım durumu güncellendi mi kontrol et
    // (Burada doğrudan state kontrolü yapamıyoruz, ancak tekrar tıklandığında stop yerine speak çağrılması gerekir)
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım tekrar başlatıldı mı kontrol et
    verify(mockAudioService.speak(any)).called(2); // Toplam 2 kez çağrılmış olmalı
  });
}
