import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';

import 'dalle_api_service_test.mocks.dart';

@GenerateMocks([http.Client, LoggingService])
void main() {
  late MockClient mockClient;
  late MockLoggingService mockLogger;
  late DalleApiService dalleApiService;

  const String testApiKey = 'test_api_key';
  const String testApiUrl = 'https://test-api-url.com';

  setUp(() {
    mockClient = MockClient();
    mockLogger = MockLoggingService();
    dalleApiService = DalleApiService.withDependencies(
      mockLogger,
      testApiKey,
      testApiUrl,
      mockClient,
    );
  });

  group('DalleApiService Tests', () {
    test('generateImage - başarılı yanıt durumu', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      final testBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      final expectedImageBytes = base64Decode(testBase64);
      
      final mockResponse = http.Response(
        jsonEncode({
          'data': [
            {'b64_json': testBase64}
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
      final result = await dalleApiService.generateImage(testPrompt);
      
      // Assert
      expect(result, expectedImageBytes);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockLogger.d(any)).called(1);
      verify(mockLogger.i(any)).called(1);
    });

    test('generateImage - HTTP hatası durumu', () async {
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
      expect(() => dalleApiService.generateImage(testPrompt), throwsException);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockLogger.d(any)).called(1);
      verify(mockLogger.e(any)).called(1);
    });

    test('generateImage - bağlantı hatası durumu', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Connection error'));
      
      // Act & Assert
      expect(() => dalleApiService.generateImage(testPrompt), throwsException);
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockLogger.d(any)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('extractBase64ImageFromResponse - geçerli yanıt yapısı', () async {
      // Arrange
      final testBase64 = 'test_base64_string';
      final testData = {
        'data': [
          {'b64_json': testBase64}
        ]
      };
      
      // Act
      final result = dalleApiService.extractBase64ImageFromResponse(testData);
      
      // Assert
      expect(result, testBase64);
    });

    test('generateImage - özel parametrelerle', () async {
      // Arrange
      final testPrompt = 'Test prompt';
      final testBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      final expectedImageBytes = base64Decode(testBase64);
      
      final mockResponse = http.Response(
        jsonEncode({
          'data': [
            {'b64_json': testBase64}
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
      final result = await dalleApiService.generateImage(
        testPrompt,
        size: '512x512',
        quality: 'hd',
        style: 'natural',
      );
      
      // Assert
      expect(result, expectedImageBytes);
      
      // Verify that the request body contains the custom parameters
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(contains('"size":"512x512"')),
      )).called(1);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(contains('"quality":"hd"')),
      )).called(1);
      
      verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: argThat(contains('"style":"natural"')),
      )).called(1);
    });
  });
}
