# Magic Book Flutter Proje Rehberi

## Komutlar
- **Derleme/Çalıştırma:** `flutter run -d <platform>` (macos, ios, android, chrome)
- **Lint:** `flutter analyze`
- **Tüm Testler:** `flutter test`
- **Tek Test:** `flutter test test/path/to/file_test.dart`
- **Widget Testi:** `flutter test test/widget_test.dart`
- **Servis Testi:** `flutter test test/core/services/service_name_test.dart`
- **Temizleme:** `flutter clean && flutter pub get`

## Kod Stili
- **Dosya düzeni:** features/modüller içinde models, repositories, screens, services, widgets
- **İsimlendirme:** camelCase değişkenler, PascalCase sınıflar, snake_case dosyalar
- **Dokümentasyon:** Tüm public API'ler, sınıflar ve önemli metotlar için /// kullan
- **Hata yönetimi:** try-catch bloklarında LoggingService kullan
- **Stil:** Flutter uygulaması AppTheme üzerinden merkezi tema yönetimi ile yapılandırılır
- **Format:** `dart format .` ile kod formatı standardize edilir
- **Enum Kuralları:** Enum sabitleri için camelCase kullanılmalı (örn. AppTheme.classic, AppTheme.fantasy)

## Loglamalar
- API yanıtlarında büyük JSON veya base64 içerikler doğrudan loglanmamalı, bunun yerine anlamlı özet mesajlar kullanılmalı
- Loglamalar için LoggingService kullanmalı ve uygun log seviyesi seçilmeli
- Verbose yerine Trace log seviyesi kullanılmalı (v() yerine t())

## BuildContext Kullanımı
- Asenkron operasyonlar sonrasında BuildContext kullanırken `if (mounted)` kontrolü yapılmalı

## Güvenlik
- API anahtarları .env dosyasında saklanmalı ve repository'de paylaşılmamalı
- Prompt enjeksiyonu saldırılarına karşı girdiler doğrulanmalı

Uygulama mimari olarak temiz mimari prensiplerini takip etmektedir. Hive veritabanı adaptörlerinin doğru sırada kaydedilmesi önemlidir (önce bağımlı olunan sınıflar, sonra bağımlı olan sınıflar).