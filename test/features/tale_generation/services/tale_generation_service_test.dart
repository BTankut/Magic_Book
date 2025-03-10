import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart';
import 'package:magic_book/features/tale_generation/services/tale_generation_service.dart';
import 'package:magic_book/shared/models/user_profile.dart';

import 'tale_generation_service_test.mocks.dart';

@GenerateMocks([GeminiApiService, DalleApiService, LoggingService])
void main() {
  late MockGeminiApiService mockGeminiApiService;
  late MockDalleApiService mockDalleApiService;
  late MockLoggingService mockLogger;
  late TaleGenerationService taleGenerationService;

  setUp(() {
    mockGeminiApiService = MockGeminiApiService();
    mockDalleApiService = MockDalleApiService();
    mockLogger = MockLoggingService();
    taleGenerationService = TaleGenerationService.withDependencies(
      mockGeminiApiService,
      mockDalleApiService,
      mockLogger,
    );
  });

  group('TaleGenerationService Entegrasyon Testleri', () {
    final testUserProfile = UserProfile(
      id: 'test_id',
      name: 'Test Kullanıcı',
      gender: Gender.boy,
      age: 8,
      hairColor: HairColor.brown,
      hairType: HairType.curly,
      skinTone: SkinTone.medium,
    );

    test('generateTale - başarılı masal üretimi', () async {
      // Arrange
      const testTitle = 'Test Masal';
      const testTheme = TaleTheme.fantasy;
      const testSetting = TaleSetting.forest;
      const testWordCount = 300;
      
      // Mock Gemini API yanıtı
      const testContent = 'Bu bir test masal içeriğidir. Ormanın derinliklerinde yaşayan küçük bir çocuk vardı.';
      when(mockGeminiApiService.generateText(any)).thenAnswer((_) async => testContent);
      
      // Mock DALL-E API yanıtı
      final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final testBase64Image = base64Encode(testImageBytes);
      when(mockDalleApiService.generateImage(any)).thenAnswer((_) async => testImageBytes);
      
      // İlerleme güncellemelerini takip etmek için
      final progressUpdates = <String>[];
      final progressValues = <double>[];
      
      taleGenerationService.onProgressUpdate = (message, progress) {
        progressUpdates.add(message);
        progressValues.add(progress);
      };
      
      // Act
      final tale = await taleGenerationService.generateTale(
        title: testTitle,
        theme: testTheme,
        setting: testSetting,
        wordCount: testWordCount,
        userProfile: testUserProfile,
      );
      
      // Assert
      expect(tale, isNotNull);
      expect(tale.title, equals(testTitle));
      expect(tale.theme, equals('fantasy'));
      expect(tale.setting, equals('forest'));
      expect(tale.userId, equals(testUserProfile.id));
      
      // Sayfa içeriği kontrolü
      expect(tale.pages, isNotEmpty);
      for (final page in tale.pages) {
        expect(page.content, isNotEmpty);
        expect(page.imageBase64, isNotNull);
      }
      
      // API çağrıları kontrolü
      verify(mockGeminiApiService.generateText(any)).called(1);
      verify(mockDalleApiService.generateImage(any)).called(tale.pages.length);
      
      // İlerleme güncellemeleri kontrolü
      expect(progressUpdates, isNotEmpty);
      expect(progressValues, isNotEmpty);
      expect(progressValues.last, equals(1.0)); // Son ilerleme değeri 1.0 olmalı
    });

    test('generateTale - Gemini API hatası durumu', () async {
      // Arrange
      const testTitle = 'Test Masal';
      const testTheme = TaleTheme.fantasy;
      const testSetting = TaleSetting.forest;
      const testWordCount = 300;
      
      // Gemini API hatası
      when(mockGeminiApiService.generateText(any)).thenThrow(Exception('API hatası'));
      
      // Act & Assert
      expect(
        () => taleGenerationService.generateTale(
          title: testTitle,
          theme: testTheme,
          setting: testSetting,
          wordCount: testWordCount,
          userProfile: testUserProfile,
        ),
        throwsException,
      );
      
      verify(mockGeminiApiService.generateText(any)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('generateTale - DALL-E API hatası durumu', () async {
      // Arrange
      const testTitle = 'Test Masal';
      const testTheme = TaleTheme.fantasy;
      const testSetting = TaleSetting.forest;
      const testWordCount = 300;
      
      // Mock Gemini API yanıtı
      const testContent = 'Bu bir test masal içeriğidir. Ormanın derinliklerinde yaşayan küçük bir çocuk vardı.';
      when(mockGeminiApiService.generateText(any)).thenAnswer((_) async => testContent);
      
      // DALL-E API hatası
      when(mockDalleApiService.generateImage(any)).thenThrow(Exception('API hatası'));
      
      // Act & Assert
      expect(
        () => taleGenerationService.generateTale(
          title: testTitle,
          theme: testTheme,
          setting: testSetting,
          wordCount: testWordCount,
          userProfile: testUserProfile,
        ),
        throwsException,
      );
      
      verify(mockGeminiApiService.generateText(any)).called(1);
      verify(mockDalleApiService.generateImage(any)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('_splitContentIntoPages - içeriği sayfalara bölme', () async {
      // Arrange
      const testContent = 'Bu bir test masal içeriğidir. Ormanın derinliklerinde yaşayan küçük bir çocuk vardı. '
          'Bir gün ormanda gezinirken kayboldu. Saatlerce yol aldı ama evini bulamadı. '
          'Sonunda bir ışık gördü ve o ışığa doğru yürüdü. Işığın kaynağı küçük bir kulübeydi. '
          'Kulübenin kapısını çaldı ve içeri girdi. İçeride yaşlı bir kadın vardı. '
          'Kadın ona yardım etmeyi kabul etti ve onu evine götürdü.';
      
      // Act
      // Reflection kullanarak private metoda erişim sağlayamadığımız için
      // generateTale metodunu çağırarak dolaylı olarak test ediyoruz
      const testTitle = 'Test Masal';
      const testTheme = TaleTheme.fantasy;
      const testSetting = TaleSetting.forest;
      const testWordCount = 300;
      
      when(mockGeminiApiService.generateText(any)).thenAnswer((_) async => testContent);
      
      final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      when(mockDalleApiService.generateImage(any)).thenAnswer((_) async => testImageBytes);
      
      final tale = await taleGenerationService.generateTale(
        title: testTitle,
        theme: testTheme,
        setting: testSetting,
        wordCount: testWordCount,
        userProfile: testUserProfile,
      );
      
      // Assert
      expect(tale.pages.length, greaterThan(1)); // En az 2 sayfa olmalı
      for (final page in tale.pages) {
        final wordCount = page.content.split(' ').length;
        expect(wordCount, lessThanOrEqualTo(50)); // Her sayfa en fazla 50 kelime içermeli
      }
    });
  });
}
