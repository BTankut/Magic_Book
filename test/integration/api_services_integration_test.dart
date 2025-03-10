import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';

// Test için basit HTTP istemcisi
class TestHttpClient extends http.BaseClient {
  final Map<String, http.Response> _responses = {};
  final Map<String, Exception> _exceptions = {};
  
  void addResponse(String urlPattern, http.Response response) {
    _responses[urlPattern] = response;
  }
  
  void addException(String urlPattern, Exception exception) {
    _exceptions[urlPattern] = exception;
  }
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url.toString();
    
    // Önce istisna kontrolü
    for (final pattern in _exceptions.keys) {
      if (url.contains(pattern)) {
        throw _exceptions[pattern]!;
      }
    }
    
    // Sonra yanıt kontrolü
    http.Response? response;
    for (final pattern in _responses.keys) {
      if (url.contains(pattern)) {
        response = _responses[pattern];
        break;
      }
    }
    
    if (response == null) {
      response = http.Response('Not found', 404);
    }
    
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  late TestHttpClient httpClient;
  late LoggingService loggingService;
  late GeminiApiService geminiApiService;
  late DalleApiService dalleApiService;

  setUp(() {
    httpClient = TestHttpClient();
    loggingService = LoggingService();
    
    // API servislerini oluştur
    geminiApiService = GeminiApiService.withDependencies(
      loggingService,
      'test_api_key',
      'https://test-api-url.com',
      httpClient,
    );

    dalleApiService = DalleApiService.withDependencies(
      loggingService,
      'test_api_key',
      'https://test-api-url.com',
      httpClient,
    );

    // GetIt'i yapılandır
    getIt.registerSingleton<LoggingService>(loggingService);
    getIt.registerSingleton<GeminiApiService>(geminiApiService);
    getIt.registerSingleton<DalleApiService>(dalleApiService);

    // Gemini API yanıtı
    final geminiResponse = '''
    {
      "candidates": [
        {
          "content": {
            "parts": [
              {
                "text": "Once upon a time, there was a small cottage in a distant forest. An old wizard lived in this cottage."
              }
            ]
          }
        }
      ]
    }
    ''';
    
    // DALL-E API yanıtı
    final dalleResponse = '''
    {
      "data": [
        {
          "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        }
      ]
    }
    ''';
    
    // Hata yanıtı
    final errorResponse = '''
    {
      "error": {
        "message": "API error occurred",
        "code": 400
      }
    }
    ''';
    
    // Başarılı yanıtları ekle
    httpClient.addResponse(
      'gemini-pro:generateContent',
      http.Response(geminiResponse, 200, headers: {'content-type': 'application/json'}),
    );
    
    httpClient.addResponse(
      'images/generations',
      http.Response(dalleResponse, 200, headers: {'content-type': 'application/json'}),
    );
    
    // Hata yanıtlarını ekle
    httpClient.addResponse(
      'error-gemini',
      http.Response(errorResponse, 400, headers: {'content-type': 'application/json'}),
    );
    
    httpClient.addResponse(
      'error-dalle',
      http.Response(errorResponse, 400, headers: {'content-type': 'application/json'}),
    );
    
    // İstisnalar ekle
    httpClient.addException(
      'exception-gemini',
      Exception('Network error occurred'),
    );
    
    httpClient.addException(
      'exception-dalle',
      Exception('Network error occurred'),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('API Servisleri Entegrasyon Testleri', () {
    test('Gemini API metin uretimi', () async {
      // Gemini API ile metin üret
      final prompt = 'Write a short fairy tale for children';
      final text = await geminiApiService.generateText(prompt);
      
      // Doğrulama
      expect(text, contains('Once upon a time'));
    });
    
    test('DALL-E API gorsel uretimi', () async {
      // DALL-E API ile görsel üret
      final imagePrompt = 'A cottage in a forest with an old wizard';
      final imageBytes = await dalleApiService.generateImage(imagePrompt);
      
      // Doğrulama
      expect(imageBytes, isNotNull);
      expect(imageBytes.length, greaterThan(0));
    });
    
    test('DALL-E API ozel parametrelerle gorsel uretimi', () async {
      // DALL-E API ile özel parametrelerle görsel üret
      final imagePrompt = 'A cottage in a forest with an old wizard';
      final imageBytes = await dalleApiService.generateImage(
        imagePrompt,
        size: '512x512',
        quality: 'hd',
        style: 'natural',
      );
      
      // Doğrulama
      expect(imageBytes, isNotNull);
      expect(imageBytes.length, greaterThan(0));
    });
  });
  
  group('API Servisleri Hata Durumları', () {
    test('Gemini API HTTP hata durumu', () async {
      // Yeni bir test istemcisi oluştur
      final testClient = TestHttpClient();
      
      // Hata yanıtı
      final errorResponse = '''
      {
        "error": {
          "message": "API error occurred",
          "code": 400
        }
      }
      ''';
      
      // Hata yanıtını ekle
      testClient.addResponse(
        'gemini-pro:generateContent',
        http.Response(errorResponse, 400, headers: {'content-type': 'application/json'}),
      );
      
      // Test için yeni bir servis oluştur
      final testService = GeminiApiService.withDependencies(
        loggingService,
        'test_api_key',
        'https://test-api-url.com',
        testClient,
      );
      
      // Gemini API ile metin üretmeyi dene
      expect(
        () => testService.generateText('Test prompt'),
        throwsException,
      );
    });
    
    test('DALL-E API HTTP hata durumu', () async {
      // Yeni bir test istemcisi oluştur
      final testClient = TestHttpClient();
      
      // Hata yanıtı
      final errorResponse = '''
      {
        "error": {
          "message": "API error occurred",
          "code": 400
        }
      }
      ''';
      
      // Hata yanıtını ekle
      testClient.addResponse(
        'images/generations',
        http.Response(errorResponse, 400, headers: {'content-type': 'application/json'}),
      );
      
      // Test için yeni bir servis oluştur
      final testService = DalleApiService.withDependencies(
        loggingService,
        'test_api_key',
        'https://test-api-url.com',
        testClient,
      );
      
      // DALL-E API ile görsel üretmeyi dene
      expect(
        () => testService.generateImage('Test prompt'),
        throwsException,
      );
    });
    
    test('Gemini API ağ hatası', () async {
      // Yeni bir test istemcisi oluştur
      final testClient = TestHttpClient();
      
      // İstisna ekle
      testClient.addException(
        'gemini-pro:generateContent',
        Exception('Network error occurred'),
      );
      
      // Test için yeni bir servis oluştur
      final testService = GeminiApiService.withDependencies(
        loggingService,
        'test_api_key',
        'https://test-api-url.com',
        testClient,
      );
      
      // Gemini API ile metin üretmeyi dene
      expect(
        () => testService.generateText('Test prompt'),
        throwsException,
      );
    });
    
    test('DALL-E API ağ hatası', () async {
      // Yeni bir test istemcisi oluştur
      final testClient = TestHttpClient();
      
      // İstisna ekle
      testClient.addException(
        'images/generations',
        Exception('Network error occurred'),
      );
      
      // Test için yeni bir servis oluştur
      final testService = DalleApiService.withDependencies(
        loggingService,
        'test_api_key',
        'https://test-api-url.com',
        testClient,
      );
      
      // DALL-E API ile görsel üretmeyi dene
      expect(
        () => testService.generateImage('Test prompt'),
        throwsException,
      );
    });
  });
}
