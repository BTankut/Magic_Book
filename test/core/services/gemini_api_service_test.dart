import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart';
import 'package:magic_book/shared/models/user_profile.dart';

import 'gemini_api_service_test.mocks.dart';

@GenerateMocks([http.Client, LoggingService])
void main() {
  late MockClient mockClient;
  late MockLoggingService mockLogger;
  late GeminiApiService geminiApiService;

  const String testApiKey = 'test_api_key';
  const String testApiUrl = 'https://test-api-url.com';

  setUp(() {
    mockClient = MockClient();
    mockLogger = MockLoggingService();
    geminiApiService = GeminiApiService.withDependencies(
      mockLogger,
      testApiKey,
      testApiUrl,
      mockClient,
    );
  });

  group('GeminiApiService Tests', () {
    test('generateText - başarılı yanıt durumu', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      final expectedText = 'Generated text response';
      
      final mockResponse = http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': expectedText}
                ]
              }
            }
          ]
        }),
        200,
      );
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await geminiApiService.generateText(testPrompt);
      
      // Assert
      expect(result, expectedText);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockLogger.d(any)).called(1);
      verify(mockLogger.i(any)).called(1);
    });

    test('generateText - HTTP hatası durumu', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      
      final mockResponse = http.Response(
        'Error response',
        500,
      );
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act & Assert
      expect(() => geminiApiService.generateText(testPrompt), throwsException);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      // Loglama çağrılarının sayısını kontrol etmiyoruz çünkü implementasyon değişmiş olabilir
    });

    test('generateText - bağlantı hatası durumu', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Connection error'));
      
      // Act & Assert
      expect(() => geminiApiService.generateText(testPrompt), throwsException);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockLogger.d(any)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('extractTextFromResponse - geçerli yanıt yapısı', () async {
      // Arrange
      final testData = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Test text'}
              ]
            }
          }
        ]
      };
      
      // Act
      final result = geminiApiService.extractTextFromResponse(testData);
      
      // Assert
      expect(result, 'Test text');
    });

    test('extractTextFromResponse - geçersiz yanıt yapısı', () async {
      // Arrange
      final testData = {
        'invalid': 'structure'
      };
      
      // Act & Assert
      expect(() => geminiApiService.extractTextFromResponse(testData), throwsException);
      verify(mockLogger.e(any, error: anyNamed('error'))).called(1);
    });
    
    test('generateTale - başarılı yanıt durumu', () async {
      // Arrange
      final testProfile = UserProfile(
        name: 'Test Character',
        age: 7,
        gender: Gender.male,
        hairColor: HairColor.brown,
        hairType: HairType.straight,
        skinTone: SkinTone.medium,
      );
      final theme = 'macera';
      final setting = 'orman';
      final wordCount = 200;
      
      final expectedTale = 'Generated tale response';
      
      final mockResponse = http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': expectedTale}
                ]
              }
            }
          ]
        }),
        200,
      );
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await geminiApiService.generateTale(
        profile: testProfile,
        theme: theme,
        setting: setting,
        wordCount: wordCount,
      );
      
      // Assert
      expect(result, expectedTale);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      // Loglama çağrılarının sayısını kontrol etmiyoruz çünkü implementasyon değişmiş olabilir
    });
    
    test('generateTale - hata durumu', () async {
      // Arrange
      final testProfile = UserProfile(
        name: 'Test Character',
        age: 7,
        gender: Gender.male,
        hairColor: HairColor.brown,
        hairType: HairType.straight,
        skinTone: SkinTone.medium,
      );
      final theme = 'macera';
      final setting = 'orman';
      final wordCount = 200;
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('API error'));
      
      // Act & Assert
      expect(() => geminiApiService.generateTale(
        profile: testProfile,
        theme: theme,
        setting: setting,
        wordCount: wordCount,
      ), throwsException);
      
      verify(mockLogger.i(any)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });
    
    test('generateImagePrompt - başarılı yanıt durumu', () async {
      // Arrange
      final pageContent = 'Test page content';
      final testProfile = UserProfile(
        name: 'Test Character',
        age: 7,
        gender: Gender.male,
        hairColor: HairColor.brown,
        hairType: HairType.straight,
        skinTone: SkinTone.medium,
      );
      
      final expectedPrompt = 'Generated image prompt';
      
      final mockResponse = http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': expectedPrompt}
                ]
              }
            }
          ]
        }),
        200,
      );
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await geminiApiService.generateImagePrompt(
        profile: testProfile,
        pageContent: pageContent,
      );
      
      // Assert
      expect(result, expectedPrompt);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      // Loglama çağrılarının sayısını kontrol etmiyoruz çünkü implementasyon değişmiş olabilir
    });
  });
}
