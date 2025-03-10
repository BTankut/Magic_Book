import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/api_constants.dart';
import 'package:magic_book/shared/models/user_profile.dart';

/// Gemini API servisi.
/// 
/// Bu servis, Gemini API'sini kullanarak metin içeriği üretir.
class GeminiApiService {
  final LoggingService _logger;
  final String _apiKey;
  final String _apiUrl;
  final http.Client _client;
  
  /// Varsayılan constructor.
  GeminiApiService()
      : _logger = getIt<LoggingService>(),
        _apiKey = ApiConstants.geminiApiKey,
        _apiUrl = ApiConstants.geminiBaseUrl,
        _client = http.Client() {
    _logger.i('GeminiApiService başlatıldı');
  }
  
  /// Test için constructor.
  GeminiApiService.withDependencies(
    this._logger,
    this._apiKey,
    this._apiUrl,
    this._client,
  );
  
  /// Verilen prompt'a göre metin üretir.
  /// 
  /// [prompt] Metin üretmek için kullanılacak prompt.
  /// [forceRefresh] Önbelleği temizleyerek yeni içerik oluşturma.
  Future<String> generateText({
    required String prompt,
    bool forceRefresh = false,
  }) async {
    try {
      _logger.i('Metin üretiliyor: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');
      
      // Önbellekten içerik kontrolü
      if (!forceRefresh) {
        // Burada önbellek kontrolü yapılabilir
        // Şu an için önbellek mekanizması uygulanmadı
      }
      
      // Gemini 1.5 Flash modelini kullan (pro yerine)
      final url = '$_apiUrl/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';
      
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
            'stopSequences': [],
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );
      
      if (response.statusCode != 200) {
        _logger.e('API hatası: ${response.statusCode} ${response.body}');
        throw Exception('API hatası: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      final text = extractTextFromResponse(data);
      
      _logger.i('Metin başarıyla üretildi: ${text.length} karakter');
      
      return text;
    } catch (e, stackTrace) {
      _logger.e('Metin üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// API yanıtından metin içeriğini çıkarır.
  String extractTextFromResponse(Map<String, dynamic> data) {
    try {
      _logger.d('API yanıtı: ${jsonEncode(data)}');
      
      // Standart yanıt formatı
      if (data.containsKey('candidates') && 
          data['candidates'] is List && 
          data['candidates'].isNotEmpty &&
          data['candidates'][0].containsKey('content') &&
          data['candidates'][0]['content'].containsKey('parts') &&
          data['candidates'][0]['content']['parts'] is List &&
          data['candidates'][0]['content']['parts'].isNotEmpty &&
          data['candidates'][0]['content']['parts'][0].containsKey('text')) {
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      }
      
      // Alternatif yanıt formatı 1 (doğrudan metin)
      if (data.containsKey('text')) {
        return data['text'] as String;
      }
      
      // Alternatif yanıt formatı 2 (content içinde doğrudan text)
      if (data.containsKey('content') && data['content'].containsKey('text')) {
        return data['content']['text'] as String;
      }
      
      // Alternatif yanıt formatı 3 (content içinde parts)
      if (data.containsKey('content') && 
          data['content'].containsKey('parts') && 
          data['content']['parts'] is List && 
          data['content']['parts'].isNotEmpty) {
        return data['content']['parts'][0]['text'] as String;
      }
      
      // Hiçbir format eşleşmedi, yanıtı detaylı logla ve hata fırlat
      _logger.e('API yanıtı bilinen formatlarla eşleşmiyor: ${jsonEncode(data)}');
      throw Exception('API yanıtı bilinen formatlarla eşleşmiyor');
    } catch (e, stackTrace) {
      _logger.e('API yanıtından metin çıkarılırken hata oluştu', error: e, stackTrace: stackTrace);
      throw Exception('API yanıtı işlenirken hata: ${e.toString()}');
    }
  }
  
  /// Özelleştirilmiş bir masal üretir.
  /// 
  /// [profile] parametresi, masalın özelleştirileceği kullanıcı profilidir.
  /// [wordCount] parametresi, masalın kelime sayısıdır.
  /// [theme] parametresi, masalın temasıdır (örn. "macera", "fantastik").
  /// [setting] parametresi, masalın geçtiği ortamdır (örn. "orman", "uzay").
  Future<String> generateTale({
    required UserProfile profile,
    required int wordCount,
    required String theme,
    required String setting,
  }) async {
    try {
      _logger.i('Masal üretiliyor: $theme, $setting, $wordCount kelime');
      
      // Prompt oluştur
      final prompt = _buildTalePrompt(
        profile: profile,
        wordCount: wordCount,
        theme: theme,
        setting: setting,
      );
      
      // Metni üret
      final generatedText = await generateText(prompt: prompt);
      
      _logger.i('Masal başarıyla üretildi: ${generatedText.length} karakter');
      return generatedText;
    } catch (e, stackTrace) {
      _logger.e('Masal üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Masal sayfası için görsel açıklaması üretir.
  /// 
  /// Bu açıklama, DALL-E API'sine gönderilecek ve görsel üretmek için kullanılacaktır.
  Future<String> generateImagePrompt({
    required UserProfile profile,
    required String pageContent,
  }) async {
    try {
      _logger.i('Görsel açıklaması üretiliyor');
      
      // Prompt oluştur
      final prompt = _buildImagePrompt(
        profile: profile,
        pageContent: pageContent,
      );
      
      // Metni üret
      final generatedPrompt = await generateText(prompt: prompt);
      
      _logger.i('Görsel açıklaması başarıyla üretildi');
      return generatedPrompt;
    } catch (e, stackTrace) {
      _logger.e('Görsel açıklaması üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Masal üretmek için prompt oluşturur.
  String _buildTalePrompt({
    required UserProfile profile,
    required int wordCount,
    required String theme,
    required String setting,
  }) {
    return '''
    Lütfen ${profile.age} yaşındaki bir çocuk için $theme temalı ve $setting ortamında geçen bir masal yaz.
    
    Masal, aşağıdaki özelliklere sahip bir karakter içermeli:
    - İsim: ${profile.name}
    - Cinsiyet: ${profile.gender}
    - Saç rengi: ${profile.hairColor}
    - Saç tipi: ${profile.hairType}
    - Ten rengi: ${profile.skinTone}
    
    Masal yaklaşık $wordCount kelime olmalı ve çocuğun yaşına uygun olmalıdır.
    
    Masal, çocuğun hayal gücünü geliştirmeli ve olumlu değerler içermelidir.
    Her paragraf en fazla 2-3 cümle içermeli ve kolay anlaşılır olmalıdır.
    
    Lütfen masalı her sayfada yaklaşık 50 kelime olacak şekilde sayfalara böl.
    Her sayfa, "Sayfa X:" şeklinde başlamalıdır.
    ''';
  }
  
  /// Görsel açıklaması üretmek için prompt oluşturur.
  String _buildImagePrompt({
    required UserProfile profile,
    required String pageContent,
  }) {
    return '''
    Lütfen aşağıdaki masal sayfası için bir çocuk kitabı illüstrasyonu açıklaması yaz.
    Bu açıklama, DALL-E API'si tarafından görsel üretmek için kullanılacak.
    
    Masal sayfası içeriği:
    "$pageContent"
    
    Görsel, aşağıdaki özelliklere sahip bir karakter içermeli:
    - İsim: ${profile.name}
    - Cinsiyet: ${profile.gender}
    - Yaş: ${profile.age}
    - Saç rengi: ${profile.hairColor}
    - Saç tipi: ${profile.hairType}
    - Ten rengi: ${profile.skinTone}
    
    Açıklama, görsel sanatçı için net ve detaylı olmalı, ancak 100 kelimeyi geçmemeli.
    Görsel, çocuk dostu, renkli ve canlı olmalı.
    Açıklama, sayfadaki ana olayı veya sahneyi yansıtmalı.
    
    Lütfen sadece görsel açıklamasını yaz, başka bir şey ekleme.
    ''';
  }
  
  /// Hata durumunda yeniden deneme veya hata fırlatma.
  Future<String> _retryOrThrow(dynamic error, String prompt) async {
    // Basit bir yeniden deneme mekanizması
    try {
      _logger.i('Gemini API isteği yeniden deneniyor...');
      
      // 2 saniye bekle ve yeniden dene
      await Future.delayed(const Duration(seconds: 2));
      
      // API isteği için URL oluştur (farklı bir model kullanarak)
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');
      
      // İstek gövdesi (daha basit yapılandırma)
      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.9,
          'maxOutputTokens': 2048,
        }
      };
      
      // API isteği gönder
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      // Yanıtı kontrol et
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Yanıt içeriğini al
        final String generatedText = extractTextFromResponse(data);
        
        _logger.i('Gemini API yeniden deneme yanıtı alındı');
        
        return generatedText;
      }
    } catch (retryError, stackTrace) {
      _logger.e('Gemini API yeniden deneme sırasında hata oluştu', error: retryError, stackTrace: stackTrace);
    }
    
    // Yeniden deneme başarısız olursa, örnek bir yanıt döndür
    _logger.w('Gemini API isteği başarısız oldu, örnek yanıt döndürülüyor');
    return _generateFallbackResponse(prompt);
  }
  
  /// Hata durumunda örnek bir yanıt döndürür.
  String _generateFallbackResponse(String prompt) {
    return 'Bir varmış bir yokmuş, uzak bir diyarda yaşayan küçük bir çocuk varmış. '
        'Bu çocuk her gün yeni maceralar keşfetmeyi çok severmiş. '
        'Bir gün, ormanın derinliklerinde parlayan bir ışık görmüş. '
        'Işığa doğru ilerlediğinde, karşısına büyülü bir kapı çıkmış. '
        'Kapıyı açtığında kendini bambaşka bir dünyada bulmuş. '
        'Burada konuşan hayvanlar, uçan arabalar ve sihirli bitkiler varmış. '
        'Çocuk bu yeni dünyada birçok arkadaş edinmiş ve birlikte güzel maceralar yaşamışlar. '
        'Günün sonunda evine döndüğünde, bu güzel macerayı asla unutmayacağını biliyormuş. '
        'Ve bir gün yine o büyülü kapıyı bulup yeni maceralara atılacağını hayal ederek uykuya dalmış.';
  }
}
