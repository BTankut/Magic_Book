import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart';
import 'package:magic_book/features/tale/screens/create_tale_screen.dart';
import 'package:magic_book/features/tale_generation/services/tale_generation_service.dart';
import 'package:magic_book/features/tale_viewer/screens/tale_viewer_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/user_profile.dart';

import 'end_to_end_test.mocks.dart';

@GenerateMocks([
  GeminiApiService, 
  DalleApiService, 
  AudioService, 
  LoggingService, 
  StorageService, 
  NetworkService
])
void main() {
  late MockGeminiApiService mockGeminiApiService;
  late MockDalleApiService mockDalleApiService;
  late MockAudioService mockAudioService;
  late MockLoggingService mockLogger;
  late MockStorageService mockStorageService;
  late MockNetworkService mockNetworkService;
  late TaleGenerationService taleGenerationService;

  setUp(() {
    mockGeminiApiService = MockGeminiApiService();
    mockDalleApiService = MockDalleApiService();
    mockAudioService = MockAudioService();
    mockLogger = MockLoggingService();
    mockStorageService = MockStorageService();
    mockNetworkService = MockNetworkService();
    
    // GetIt'i yapılandır
    getIt.registerSingleton<GeminiApiService>(mockGeminiApiService);
    getIt.registerSingleton<DalleApiService>(mockDalleApiService);
    getIt.registerSingleton<AudioService>(mockAudioService);
    getIt.registerSingleton<LoggingService>(mockLogger);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<NetworkService>(mockNetworkService);
    
    // TaleGenerationService'i yapılandır
    taleGenerationService = TaleGenerationService.withDependencies(
      mockGeminiApiService,
      mockDalleApiService,
      mockLogger,
    );
    getIt.registerSingleton<TaleGenerationService>(taleGenerationService);
  });

  tearDown(() {
    // GetIt'i temizle
    getIt.reset();
  });

  // Test için örnek bir kullanıcı profili oluştur
  UserProfile createTestUserProfile() {
    return UserProfile(
      id: 'test_user_id',
      name: 'Test Kullanıcı',
      gender: Gender.boy,
      age: 8,
      hairColor: HairColor.brown,
      hairType: HairType.curly,
      skinTone: SkinTone.medium,
    );
  }

  testWidgets('Uçtan uca masal oluşturma ve görüntüleme süreci', (WidgetTester tester) async {
    // Arrange
    final testUserProfile = createTestUserProfile();
    
    // StorageService mock yapılandırması
    when(mockStorageService.getActiveUserProfile()).thenReturn('test_user_id');
    when(mockStorageService.getUserProfile('test_user_id')).thenReturn(testUserProfile);
    
    // NetworkService mock yapılandırması
    when(mockNetworkService.getCurrentNetworkStatus()).thenAnswer((_) async => NetworkStatus.online);
    when(mockNetworkService.networkStatusStream).thenAnswer((_) => Stream.value(NetworkStatus.online));
    
    // GeminiApiService mock yapılandırması
    const testContent = 'Bu bir test masal içeriğidir. Ormanın derinliklerinde yaşayan küçük bir çocuk vardı.';
    when(mockGeminiApiService.generateText(any)).thenAnswer((_) async => testContent);
    
    // DalleApiService mock yapılandırması
    final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    when(mockDalleApiService.generateImage(any)).thenAnswer((_) async => testImageBytes);
    
    // AudioService mock yapılandırması
    when(mockAudioService.speak(any)).thenAnswer((_) async {});
    when(mockAudioService.stop()).thenAnswer((_) async {});
    
    // StorageService.saveTale ve getTale mock yapılandırması
    when(mockStorageService.saveTale(any)).thenAnswer((invocation) {
      final tale = invocation.positionalArguments[0] as Tale;
      return tale.copyWith(id: 'test_tale_id');
    });
    
    when(mockStorageService.getTale('test_tale_id')).thenAnswer((invocation) {
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
            content: testContent,
            imageBase64: base64Encode(testImageBytes),
            audioBase64: null,
          ),
        ],
      );
    });
    
    // Act - CreateTaleScreen widget'ını oluştur
    await tester.pumpWidget(
      MaterialApp(
        home: CreateTaleScreen(),
      ),
    );
    
    // Yükleme durumunu bekle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Masal başlığını gir
    await tester.enterText(find.byType(TextFormField).first, 'Test Masal');
    
    // Masal oluştur düğmesini bul ve tıkla
    final createButton = find.text('Masal Oluştur');
    expect(createButton, findsOneWidget);
    await tester.tap(createButton);
    await tester.pumpAndSettle();
    
    // TaleGenerationScreen'e geçildi mi kontrol et
    expect(find.text('Masal Oluşturuluyor'), findsOneWidget);
    
    // API çağrıları yapıldı mı kontrol et
    verify(mockGeminiApiService.generateText(any)).called(1);
    verify(mockDalleApiService.generateImage(any)).called(1);
    
    // TaleViewerScreen'e geçiş için bekle
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    
    // TaleViewerScreen'e geçildi mi kontrol et
    expect(find.text('Test Masal'), findsOneWidget);
    expect(find.text(testContent), findsOneWidget);
    
    // Ses düğmesini bul ve tıkla
    final audioButton = find.byIcon(Icons.volume_up);
    expect(audioButton, findsOneWidget);
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım başlatıldı mı kontrol et
    verify(mockAudioService.speak(testContent)).called(1);
    
    // Ses düğmesini tekrar tıkla (durdurma)
    await tester.tap(audioButton);
    await tester.pump();
    
    // Sesli anlatım durduruldu mu kontrol et
    verify(mockAudioService.stop()).called(1);
    
    // Favori düğmesini bul ve tıkla
    final favoriteButton = find.byIcon(Icons.favorite_border);
    expect(favoriteButton, findsOneWidget);
    await tester.tap(favoriteButton);
    await tester.pump();
    
    // Favori durumu güncellendi mi kontrol et
    verify(mockStorageService.updateTale(any)).called(1);
  });
}
