import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API sabitleri.
/// 
/// Bu sınıf, API istekleri için gerekli sabitleri içerir.

class ApiConstants {
  // Gemini API sabitleri
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // DALL-E API sabitleri
  static const String dalleBaseUrl = 'https://api.openai.com';
  static String get dalleApiKey => dotenv.env['DALLE_API_KEY'] ?? '';
  
  // API istekleri için zaman aşımı değerleri (saniye)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 60;
  
  // API güvenliği için notlar
  // NOT: Gerçek bir uygulamada, API anahtarlarını doğrudan kodda saklamak güvenlik açısından uygun değildir.
  // Bu anahtarlar, flutter_dotenv gibi bir paket kullanılarak .env dosyasından alınmalıdır.
  // Ayrıca, API isteklerinin backend üzerinden yapılması, anahtarların cihazda saklanmaması daha güvenlidir.
  // Örnek:
  // static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  // static String get dalleApiKey => dotenv.env['DALLE_API_KEY'] ?? '';
}
