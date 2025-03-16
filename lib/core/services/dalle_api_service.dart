import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/api_constants.dart';

/// DALL-E API servisi.
/// 
/// Bu servis, DALL-E API'sini kullanarak masal sayfaları için 
/// görsellerin üretilmesini sağlar.
class DalleApiService {
  final LoggingService _logger;
  final ImageCacheService _imageCacheService;
  final String _apiKey;
  final String _apiUrl;
  final http.Client _client;
  
  // API isteği yeniden deneme parametreleri
  final int _maxRetries;
  final Duration _initialBackoff;
  final double _backoffMultiplier;
  
  // Eş zamanlı istek sınırlaması için
  static const int _maxConcurrentRequests = 3;
  final _requestSemaphore = Semaphore(_maxConcurrentRequests);
  
  /// Varsayılan constructor.
  DalleApiService()
      : _logger = getIt<LoggingService>(),
        _imageCacheService = getIt<ImageCacheService>(),
        _apiKey = ApiConstants.dalleApiKey,
        _apiUrl = ApiConstants.dalleBaseUrl,
        _client = http.Client(),
        _maxRetries = 3,
        _initialBackoff = Duration(seconds: 1),
        _backoffMultiplier = 2.0 {
    _logger.i('DalleApiService başlatıldı');
  }
  
  /// Test için constructor.
  DalleApiService.withDependencies(
    this._logger,
    this._apiKey,
    this._apiUrl,
    this._client,
  ) : _imageCacheService = getIt<ImageCacheService>(),
      _maxRetries = 3,
      _initialBackoff = Duration(seconds: 1),
      _backoffMultiplier = 2.0;
  
  /// Verilen açıklamaya göre bir görsel üretir.
  /// 
  /// [prompt] parametresi, görselin açıklamasıdır.
  /// [size] parametresi, görselin boyutudur (örn. "1024x1024").
  /// [quality] parametresi, görselin kalitesidir (örn. "standard", "hd").
  /// [style] parametresi, görselin tarzıdır (örn. "vivid", "natural").
  /// [forceRefresh] Önbelleği temizleyerek yeni görsel oluşturma.
  Future<String?> generateImage({
    required String prompt,
    String size = '1024x1024',
    String quality = 'standard',
    String style = 'vivid',
    bool forceRefresh = false,
  }) async {
    try {
      // Önbellek anahtarı oluştur
      final cacheKey = _generateCacheKey(prompt, size, quality, style);
      
      // Önbellekte kontrol et (forceRefresh false ise)
      if (!forceRefresh) {
        final cachedImage = await _imageCacheService.getImage(cacheKey);
        if (cachedImage != null) {
          _logger.i('Görsel önbellekten yüklendi: $cacheKey');
          return base64Encode(cachedImage);
        }
      } else {
        _logger.i('Önbellek temizleme aktif: Görsel yeniden oluşturuluyor');
      }
      
      _logger.i('Görsel üretiliyor: ${prompt.substring(0, prompt.length > 30 ? 30 : prompt.length)}...');
      
      // Yeniden deneme mekanizması ile API isteği gönder
      return await _requestWithRetry(
        prompt: prompt,
        size: size, 
        quality: quality,
        style: style,
        cacheKey: cacheKey
      );
    } catch (e, stackTrace) {
      _logger.e('Görsel üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Yeniden deneme mekanizması ile API isteği gönderir.
  Future<String?> _requestWithRetry({
    required String prompt,
    required String size,
    required String quality,
    required String style,
    required String cacheKey,
  }) async {
    int attempts = 0;
    Duration backoff = _initialBackoff;
    
    while (attempts < _maxRetries) {
      attempts++;
      
      try {
        // Semaphore kullanarak eş zamanlı istek sayısını sınırla
        return await _requestSemaphore.run(() async {
          final url = Uri.parse('$_apiUrl/v1/images/generations');
          
          final response = await _client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'prompt': prompt,
              'model': 'dall-e-3',
              'n': 1,
              'size': size,
              'quality': quality,
              'style': style,
              'response_format': 'b64_json',
            }),
          );
          
          // Hata yanıtlarını işle ve uygun şekilde ele al
          if (response.statusCode != 200) {
            final errorResponse = _parseErrorResponse(response);
            
            switch (response.statusCode) {
              case 400:
                _logger.e('400 Bad Request: ${errorResponse.message}');
                
                // İçerik politikası hatası için uyarı log'u
                if (errorResponse.code == 'content_policy_violation') {
                  _logger.w('İçerik politikası ihlali. Prompt: $prompt');
                  throw Exception('İçerik politikası ihlali: ${errorResponse.message}');
                }
                
                // Yanlış formatlı prompt
                throw Exception('API istek hatası: ${errorResponse.message}');
                
              case 401:
                _logger.e('401 Unauthorized: API anahtarı geçersiz');
                throw Exception('API anahtarı geçersiz veya eksik');
                
              case 403:
                _logger.e('403 Forbidden: ${errorResponse.message}');
                throw Exception('Erişim reddedildi: ${errorResponse.message}');
                
              case 404:
                _logger.e('404 Not Found: ${errorResponse.message}');
                throw Exception('API endpoint bulunamadı');
                
              case 429:
                _logger.w('429 Rate Limit: ${errorResponse.message}');
                
                // Retry-After başlığını kontrol et
                final retryAfter = response.headers['retry-after'];
                if (retryAfter != null) {
                  int retrySeconds = int.tryParse(retryAfter) ?? backoff.inSeconds;
                  backoff = Duration(seconds: retrySeconds);
                }
                
                // Yeniden deneme için istisna fırlat (yakalanacak)
                throw _RetryableException('Rate limit aşıldı', backoff);
                
              case 500:
              case 503:
                _logger.e('${response.statusCode} Server Error: ${errorResponse.message}');
                // Sunucu hatası - yeniden denenebilir
                throw _RetryableException('OpenAI sunucu hatası', backoff);
                
              default:
                _logger.e('Beklenmeyen hata kodu: ${response.statusCode}');
                throw Exception('API hatası: ${response.statusCode} - ${errorResponse.message}');
            }
          }
          
          final data = jsonDecode(response.body);
          final base64Image = extractBase64ImageFromResponse(data);
          final imageBytes = base64Decode(base64Image);
          
          // Görseli önbelleğe ekle
          await _imageCacheService.cacheImage(cacheKey, imageBytes);
          _logger.i('Görsel başarıyla üretildi ve önbelleğe eklendi: ${imageBytes.length} byte');
          
          return base64Image;
        });
      } catch (e) {
        // Sadece belirli hatalarda yeniden deneme yap
        if (e is _RetryableException) {
          if (attempts < _maxRetries) {
            _logger.i('Yeniden deneme ${attempts}/${_maxRetries}: ${e.backoff.inSeconds} saniye bekleniyor...');
            await Future.delayed(e.backoff);
            backoff = Duration(seconds: (backoff.inSeconds * _backoffMultiplier).round());
            continue;
          }
        }
        
        // Son deneme veya yeniden denememeye değer bir hata - yeniden fırlat
        rethrow;
      }
    }
    
    // Tüm denemeler başarısız oldu
    _logger.e('Maksimum yeniden deneme sayısına ulaşıldı ($_maxRetries)');
    throw Exception('Görsel oluşturulamadı: Maksimum yeniden deneme sayısına ulaşıldı');
  }
  
  /// API hata yanıtını ayrıştırır.
  _ErrorResponse _parseErrorResponse(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      
      // OpenAI API hata formatı
      if (jsonResponse.containsKey('error')) {
        final error = jsonResponse['error'];
        return _ErrorResponse(
          message: error['message'] ?? 'Bilinmeyen hata',
          type: error['type'] ?? 'api_error',
          code: error['code'],
        );
      }
      
      // Genel hata formatı
      return _ErrorResponse(
        message: jsonResponse['message'] ?? 'API hatası: ${response.statusCode}',
        type: jsonResponse['type'] ?? 'api_error',
        code: jsonResponse['code'],
      );
    } catch (e) {
      // JSON ayrıştırma hatası
      return _ErrorResponse(
        message: 'API yanıtı ayrıştırılamadı: ${response.body}',
        type: 'parse_error',
      );
    }
  }
  
  /// API yanıtından base64 formatındaki görseli çıkarır.
  String extractBase64ImageFromResponse(Map<String, dynamic> data) {
    try {
      _logger.d('API yanıtı alındı: DALLE API yanıtı (base64 görsel içeriyor)');
      
      // Standart yanıt formatı
      if (data.containsKey('data') && 
          data['data'] is List && 
          data['data'].isNotEmpty &&
          data['data'][0].containsKey('b64_json')) {
        return data['data'][0]['b64_json'] as String;
      }
      
      // Alternatif yanıt formatı 1 (doğrudan b64_json)
      if (data.containsKey('b64_json')) {
        return data['b64_json'] as String;
      }
      
      // Alternatif yanıt formatı 2 (image içinde b64_json)
      if (data.containsKey('image') && data['image'].containsKey('b64_json')) {
        return data['image']['b64_json'] as String;
      }
      
      // Alternatif yanıt formatı 3 (images dizisi)
      if (data.containsKey('images') && 
          data['images'] is List && 
          data['images'].isNotEmpty) {
        if (data['images'][0] is String) {
          return data['images'][0] as String;
        } else if (data['images'][0] is Map && data['images'][0].containsKey('b64_json')) {
          return data['images'][0]['b64_json'] as String;
        }
      }
      
      // Hiçbir format eşleşmedi, yanıtı detaylı logla ve hata fırlat
      _logger.e('API yanıtı bilinen formatlarla eşleşmiyor');
      throw Exception('API yanıtı bilinen formatlarla eşleşmiyor');
    } catch (e, stackTrace) {
      _logger.e('API yanıtından görsel çıkarılırken hata oluştu', error: e, stackTrace: stackTrace);
      throw Exception('API yanıtı işlenirken hata: ${e.toString()}');
    }
  }
  
  /// Görseli Base64 formatına dönüştürür.
  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }
  
  /// Base64 formatındaki görseli byte dizisine dönüştürür.
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }
  
  /// Önbellek anahtarı oluşturur.
  String _generateCacheKey(String prompt, String size, String quality, String style) {
    try {
      // Önbellek anahtarı için giriş verilerini hazırla
      final input = '$prompt-$size-$quality-$style';
      
      // Uzun promptları kısalt (hash için yeterli)
      final truncatedInput = input.length > 1000 ? input.substring(0, 1000) : input;
      
      // SHA-256 hash oluştur
      final bytes = utf8.encode(truncatedInput);
      final digest = sha256.convert(bytes);
      final hash = digest.toString();
      
      // Önbellek anahtarı formatı: dalle_<hash>
      final cacheKey = 'dalle_$hash';
      
      _logger.d('Önbellek anahtarı oluşturuldu: $cacheKey');
      return cacheKey;
    } catch (e, stackTrace) {
      _logger.e('Önbellek anahtarı oluşturulurken hata oluştu', error: e, stackTrace: stackTrace);
      
      // Hata durumunda basit bir hash oluştur (yedek mekanizma)
      final fallbackHash = prompt.hashCode.toString();
      return 'dalle_fallback_$fallbackHash';
    }
  }
  
  /// Servisi temizler.
  void dispose() {
    _client.close();
  }
}

/// Yeniden deneme yapılabilir hatalar için istisna sınıfı.
class _RetryableException implements Exception {
  final String message;
  final Duration backoff;
  
  _RetryableException(this.message, this.backoff);
  
  @override
  String toString() => 'RetryableException: $message (Backoff: ${backoff.inSeconds}s)';
}

/// API hata yanıtı modeli.
class _ErrorResponse {
  final String message;
  final String type;
  final String? code;
  
  _ErrorResponse({
    required this.message,
    required this.type,
    this.code,
  });
}

/// Eş zamanlı istekleri yönetmek için semafor uygulaması.
class Semaphore {
  final int _maxConcurrent;
  int _current = 0;
  final _queue = <Completer<void>>[];
  
  Semaphore(this._maxConcurrent);
  
  Future<T> run<T>(Future<T> Function() task) async {
    await _acquire();
    try {
      return await task();
    } finally {
      _release();
    }
  }
  
  Future<void> _acquire() async {
    if (_current < _maxConcurrent) {
      _current++;
      return;
    }
    
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }
  
  void _release() {
    if (_queue.isEmpty) {
      _current--;
    } else {
      final completer = _queue.removeAt(0);
      completer.complete();
    }
  }
}
