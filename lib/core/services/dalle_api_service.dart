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
  
  /// Varsayılan constructor.
  DalleApiService()
      : _logger = getIt<LoggingService>(),
        _imageCacheService = getIt<ImageCacheService>(),
        _apiKey = ApiConstants.dalleApiKey,
        _apiUrl = ApiConstants.dalleBaseUrl,
        _client = http.Client() {
    _logger.i('DalleApiService başlatıldı');
  }
  
  /// Test için constructor.
  DalleApiService.withDependencies(
    this._logger,
    this._apiKey,
    this._apiUrl,
    this._client,
  ) : _imageCacheService = getIt<ImageCacheService>();
  
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
      
      if (response.statusCode != 200) {
        _logger.e('API hatası: ${response.statusCode} ${response.body}');
        throw Exception('API hatası: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      final base64Image = extractBase64ImageFromResponse(data);
      final imageBytes = base64Decode(base64Image);
      
      // Görseli önbelleğe ekle
      await _imageCacheService.cacheImage(cacheKey, imageBytes);
      _logger.i('Görsel başarıyla üretildi ve önbelleğe eklendi: ${imageBytes.length} byte');
      
      return base64Image;
    } catch (e, stackTrace) {
      _logger.e('Görsel üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// API yanıtından base64 formatındaki görseli çıkarır.
  String extractBase64ImageFromResponse(Map<String, dynamic> data) {
    try {
      _logger.d('API yanıtı: ${jsonEncode(data)}');
      
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
      _logger.e('API yanıtı bilinen formatlarla eşleşmiyor: ${jsonEncode(data)}');
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
  
  /// İki değerden küçük olanını döndürür.
  int _min(int a, int b) => a < b ? a : b;
}
