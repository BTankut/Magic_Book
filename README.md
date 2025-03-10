# Magic Book

Magic Book, 0-12 yaş arası çocuklar için kişiselleştirilmiş masallar üreten interaktif bir mobil uygulamadır. Uygulama, kullanıcı girdilerine dayalı olarak özgün masallar oluşturur ve bu masalları görsellerle ve sesli anlatımla zenginleştirir.

## Özellikler

- **Kişiselleştirilmiş Masal Üretimi**: Kullanıcı profili ve tercihlerine göre özelleştirilmiş masallar
- **Kullanıcı Profili Özelleştirme**: İsim, cinsiyet, yaş, saç rengi, saç tipi, ten rengi gibi özelliklerin ayarlanması
- **Favoriler Sistemi**: En sevilen masalların kaydedilmesi (maksimum 5 masal)
- **Metinden Sese Dönüştürme**: Masalların sesli anlatımı
- **Çevrimdışı Erişim**: Kaydedilen masallara internet bağlantısı olmadan erişim
- **Gerçekçi Kitap Arayüzü**: Sayfa çevirme animasyonları ve antik kitap görünümü
- **Performans Optimizasyonu**: Görsel önbelleğe alma ve hızlı yükleme özellikleri
- **Akıllı Önbellek Yönetimi**: Tekrarlanan API çağrılarını azaltmak için LRU (Least Recently Used) önbellek sistemi

## Teknoloji Yığını

- **Frontend Çerçevesi**: Flutter (Dart)
- **Durum Yönetimi**: Provider/Riverpod
- **Yerel Depolama**: Hive/SQLite
- **API Entegrasyonu**: 
  - Gemini 2.0 Flash (metin üretimi)
  - DALL-E 3 (görsel üretimi)
- **Ses**: Flutter TTS (metinden sese dönüştürme)
- **UI Bileşenleri**: Özel kitap arayüzü ve sayfa çevirme animasyonları
- **Önbellek Yönetimi**: LRU Cache (bellek içi) ve dosya sistemi (kalıcı depolama)

## Kurulum

1. Flutter SDK'yı yükleyin (https://flutter.dev/docs/get-started/install)
2. Projeyi klonlayın: `git clone https://github.com/BTankut/Magic_Book.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. `.env.example` dosyasını kopyalayarak `.env` dosyası oluşturun ve API anahtarlarınızı ayarlayın:
   ```bash
   cp .env.example .env
   ```
   Ardından `.env` dosyasını düzenleyerek kendi API anahtarlarınızı ekleyin:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   DALLE_API_KEY=your_dalle_api_key_here
   ```
5. Uygulamayı çalıştırın: 
   - macOS için: `flutter run -d macos`
   - iOS için: `flutter run -d ios`
   - Android için: `flutter run -d android`
   - Web için: `flutter run -d chrome`

### macOS için Ek Gereksinimler

macOS'ta çalıştırmak için:

1. CocoaPods yüklü olmalıdır: `brew install cocoapods` veya `sudo gem install cocoapods`
2. Minimum macOS sürümü 10.15 veya üzeri olmalıdır (flutter_tts eklentisi gereksinimleri)

## Proje Yapısı

Proje, Clean Architecture ve modüler yapı prensipleri gözetilerek tasarlanmıştır:

```
lib/
├── core/           # Çekirdek bileşenler
│   ├── services/   # API servisleri ve yardımcı servisler
│   │   ├── audio_service.dart         # Sesli anlatım servisi
│   │   ├── dalle_api_service.dart     # DALL-E API servisi
│   │   ├── gemini_api_service.dart    # Gemini API servisi
│   │   ├── image_cache_service.dart   # Görsel önbellek servisi
│   │   ├── logging_service.dart       # Günlük kaydı servisi
│   │   ├── network_service.dart       # Ağ durumu servisi
│   │   ├── storage_service.dart       # Hive depolama servisi
│   │   └── download_manager.dart      # İndirme yöneticisi
│   ├── theme/      # Tema ayarları
│   └── utils/      # Yardımcı fonksiyonlar
├── features/       # Özellik modülleri
│   ├── home/           # Ana ekran
│   ├── onboarding/     # Karşılama ekranları
│   ├── profile/        # Profil ekranları
│   ├── tale/           # Masal oluşturma
│   ├── tale_generation/# Masal üretimi
│   ├── tale_viewer/    # Masal görüntüleme
│   ├── favorites/      # Favoriler ekranı
│   └── user_profile/   # Kullanıcı profili
├── shared/         # Paylaşılan bileşenler
│   ├── constants/  # Sabitler
│   ├── enums/      # Enumlar
│   ├── models/     # Veri modelleri (tale.dart, user_profile.dart)
│   ├── theme/      # Tema tanımları
│   └── widgets/    # Ortak widget'lar
├── app.dart        # Uygulama tanımı
└── main.dart       # Giriş noktası
```

## Performans Optimizasyonları

Uygulama, aşağıdaki performans iyileştirmelerini içerir:

- **Görsel Önbelleğe Alma**: Görseller hem bellek içinde hem de disk üzerinde önbelleğe alınır
- **Akıllı API Çağrıları**: Aynı parametrelerle yapılan tekrarlanan API çağrıları önlenir
- **Asenkron Görsel Yükleme**: UI donmalarını önlemek için görsel yükleme işlemleri arka planda gerçekleştirilir
- **Verimli Base64 İşleme**: Tekrarlanan base64 çözme işlemleri önbellek kullanılarak optimize edilir

## Katkıda Bulunma

1. Projeyi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Hata Giderme

Uygulamayı çalıştırırken karşılaşabileceğiniz bazı yaygın sorunlar ve çözümleri:

1. **Hive Adaptör Kayıt Sorunları**: "Cannot write, unknown type: X. Did you forget to register an adapter?" hatası alıyorsanız, adaptörlerin doğru sırada kaydedildiğinden emin olun. Önce bağımlı olunan sınıfların adaptörleri (enum'lar ve basit sınıflar), sonra bağımlı olan sınıfların adaptörleri kaydedilmelidir.

2. **API Yanıt Format Sorunları**: API yanıtlarında değişiklik olduğunda, `extractTextFromResponse` ve `extractBase64ImageFromResponse` metodlarını kontrol edin.

3. **Önbellek Anahtar Oluşturma Sorunları**: Uzun promptlar için önbellek anahtarı oluştururken hata alıyorsanız, hash oluşturma işlemini kontrol edin.

4. **Görsel Sorunları**: Görseller yüklenemiyorsa, önbellekte ve disk üzerinde doğru şekilde saklandıklarından emin olun.

## Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
