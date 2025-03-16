# FableWhisper - Yenilenmiş Geliştirme Roadmap

## Genel Bakış

Bu doküman, "FableWhisper" uygulamasının (eski adıyla Magic Book) geliştirme yol haritasını içerir. FableWhisper, 0-12 yaş arası çocuklar için etkileşimli bir masal uygulamasıdır. Uygulama, kullanıcı girişine göre özelleştirilmiş masallar oluşturacak, görseller ve sesli anlatım içerecektir. Çapraz platform uyumluluğu için Flutter ile geliştirilen uygulama, otantik kitap benzeri bir okuma deneyimi sağlayan modern bir arayüze sahip olacaktır.

Bu yenilenmiş versiyonda tema sisteminin karmaşıklığı giderilecek ve **tek bir sabit tema** kullanılacaktır. Bu yaklaşım, kodun daha basit ve bakımı daha kolay olmasını sağlayacaktır.

## Proje Özellikleri

- **Uygulama Adı**: FableWhisper
- **Hedef Kitle**: 0-12 yaş arası çocuklar
- **Platformlar**: 
  - iOS (iPhone ve iPad uyumlu)
  - Android
  - Web
- **Çoklu Cihaz Desteği**: Paylaşılan yerel depolama ve veri senkronizasyonu
- **AI Entegrasyonu**: 
  - Gemini Pro 1.5 Flash (metin üretimi)
  - DALL-E 3 (görsel üretimi)
- **Temel Özellikler**:
  - Kişiselleştirilmiş masal üretimi
  - Basit kullanıcı profili oluşturma (maksimum 5 profil)
  - Favoriler sistemi (maksimum 5 masal)
  - Metinden sese çevirme
  - Kaydedilen masallara çevrimdışı erişim
  - Basitleştirilmiş, **tek temaya sahip** arayüz
  - **Not**: Email veya şifre tabanlı kullanıcı kimlik doğrulama gerekmeyecek

## Aşama 1: Proje Kurulumu ve Mimari

### 1.1 Proje Başlatma
- Yeni bir Flutter projesi oluştur
- Modüler mimariye göre proje yapısını kur
- Versiyon kontrolünü konfigüre et (Git)
- Flutter sürüm yönetimi (FVM) ile sürüm kontrolü
- `.env` dosyası ile ortam değişkenleri yapılandırması (API anahtarları)
- **Web, iPhone ve iPad platformları için Flutter yapılandırma ayarlarını yap**

### 1.2 Bağımlılık Yönetimi
- Temel paketleri ekle:
  - `dio` (API iletişimi için daha esnek çözüm)
  - `hive` ve `hive_flutter` (yerel depolama)
  - `flutter_riverpod` (durum yönetimi)
  - `flutter_tts` (metinden sese çevirme)
  - `page_turn` (kitap sayfası animasyonu)
  - `lottie` (yükleme ve durum animasyonları)
  - `cached_network_image` (görsel önbellekleme)
  - `flutter_dotenv` (ortam değişkenleri yönetimi)
  - `path_provider` (dosya sistemi erişimi)
  - `mockito` ve `fake_async` (test için)
  - `flutter_native_splash` (splash ekranı)
  - `connectivity_plus` (ağ durumu kontrolü)

### 1.3 Mimari Kurulum
- Temiz Mimari uygula:
  - Repository deseni (veri katmanı)
  - Servis katmanı (iş mantığı)
  - Presentation katmanı (UI ve viewmodels)
- Asenkron işlemler için Result/Either deseni kullan (hata yönetimi)
- Riverpod ile reaktif durum yönetimi
- Platform tespiti ve platform özel ayarlamalar
- Bağımlılık enjeksiyonu için Provider kullan

## Aşama 2: Temel Servis Uygulamaları

### 2.1 API Servisleri
- `NetworkService`: Tüm API istekleri için temel sınıf (interceptor, hata yönetimi)
- `GeminiApiService`: Masal üretimi ve metnin yapılandırılması
  - İstek ve yanıt modelleri
  - Hata yönetimi, retry mekanizması
  - Masal yapılandırma promptları
- `DalleApiService`: Görsel üretimi için
  - İstek ve yanıt modelleri
  - Hata yönetimi ve retry mekanizması
  - Context-aware prompt hazırlama 
- `LoggingService`: API çağrılarını ve hataları izlemek için (debug ve release modları farklı)

### 2.2 Yerel Depolama ve Senkronizasyon
- `StorageService`: Profilin, masalların ve ayarların temel depolanması
  - Hive adaptörleri ve şema yönetimi
  - Veri sürüm kontrolü
- `ImageCacheService`: Görseller için önbellekleme
  - Dosya sistemi ve memory cache yönetimi 
- `DownloadManager`: Favorilerin tam olarak indirilmesi
  - İlerleme izleme
  - Kesintiye uğrayan indirmeleri devam ettirme
- Platformlar arası veri paylaşımı:
  - İçe/dışa aktarma (JSON formatı)
  - Web için IndexedDB entegrasyonu

### 2.3 Metinden Sese Servisi
- `AudioService`: TTS ve ses dosyası yönetimi
  - Oynatma kontrolleri (başlat, duraklat, durdur)
  - Sesi dosya olarak kaydetme
  - Farklı sesler ve hız seçenekleri
  - Platform özel ses çözümleri (özellikle web için)

## Aşama 3: Temel Veri Modelleri

### 3.1 Veri Modelleri
- `UserProfile`: Kullanıcı profil bilgileri
  - Temel kişisel bilgiler (isim, yaş)
  - Fiziksel özellikler (saç rengi, saç tipi, ten tonu)
  - Oluşturma ve güncelleme tarihi
  - Önbellek yapılandırmaları

- `Tale`: Masal bilgileri
  - Meta veriler (başlık, oluşturma tarihi, vb.)
  - Sayfa koleksiyonu
  - Toplam kelime sayısı
  - Tamamlanma durumu
  - Önbellek durumu

- `TalePage`: Masal sayfası
  - Sayfa numarası
  - Metin içeriği
  - Görsel verisi (Base64 veya dosya yolu)
  - Ses dosyası yolu

### 3.2 Repository İmplementasyonları
- `ProfileRepository`: Kullanıcı profillerinin yönetimi
- `TaleRepository`: Masal üretimi ve yönetimi
- `FavoritesRepository`: Favori masalların yönetimi

## Aşama 4: Kullanıcı Arayüzü Geliştirmesi

### 4.1 UI Temeli ve Tema Sistemi
- Tek ve tutarlı tema sistemi:
  - Krem rengi tonlarında renk paleti
  - Yazı rengi her zaman zemininden daha koyu
  - Buton metni her zaman buton zemininden daha koyu
  - Tüm renk ve tipografi değerleri merkezi olarak tanımlı
  - MediaQuery kullanımı ve farklı ekranlara duyarlılık

### 4.2 Ortak Bileşenler
- `FableButton`: Özel tasarlanmış dönem temalı buton
- `ResponsiveContainer`: Farklı ekranlara uyarlanabilen kapsayıcı
- `PlatformAwareWidget`: Platform bazlı farklı görünümler
- `WhisperLoadingIndicator`: Masal üretimi sürecinde kullanılacak tematik yükleme göstergesi
- `ErrorDisplay`: Hata mesajları için standart görünüm
- `NetworkStatusBanner`: Çevrimdışı durumu bildirme

### 4.3 Ekranlar ve Kullanıcı Akışları
- **Başlangıç ve Profil Ekranları**:
  - Karşılama ekranı ve ilk profil oluşturma
  - Profil listesi ve seçimi
  - Profil düzenleme ve silme

- **Ana Ekran ve Navigasyon**:
  - Ana ekranda profil özeti ve seçenekler
  - Yeni masal, favoriler ve ayarlar için gezinme
  - Cihaz tipine göre uyarlanmış navigasyon (bottom bar veya side drawer)

- **Masal Üretim Ekranları**:
  - Masal parametreleri girişi ve önizlemesi
  - Üretim ilerleme gösterimi
  - Animasyonlu durum bildirimleri

- **Masal Kitap Arayüzü**:
  - Book widget ile sayfa çevirme animasyonu
  - Sol sayfada metin, sağ sayfada görsel düzeni
  - Sayfa numarası gösterimi ve hızlı geçiş
  - Ses kontrol düğmeleri
  - "Favorilere Ekle" butonu
  - iPad özel düzeni (yatay modda geniş görünüm)

- **Favoriler Ekranı**:
  - Masalların thumbnail listesi
  - İndirme durumu göstergeleri 
  - Meta veriler (yaratılma tarihi, okuma süresi, vb.)
  - Masalı silme ve içe/dışa aktarma seçenekleri

## Aşama 5: Masal Üretim İş Akışı

### 5.1 Tale Generation İş Akışı
- `TaleGenerationViewModel`: UI ve iş mantığı arasında köprü
  - Kullanıcı girdilerini işleme
  - Durum yönetimi (yükleniyor, hata, tamamlandı)
  - İlerleme bildirimleri

- Masal oluşturma süreci:
  1. Kullanıcı girdileri ve profil bilgilerini harmanlama
  2. Gemini API'ye istek gönderme
  3. Masal metnini sayfalara bölme (sayfa başına ~50 kelime)
  4. Her sayfa için görsel üretimi
  5. Metinden sese dönüşüm ve ses dosyası kaydetme
  6. Tale nesnesini oluşturma ve UI'a iletme

### 5.2 Prompt Mühendisliği
- **Metni yapılandırma** için prompt stratejileri:
  - Yaş grubuna uygun dil ve içerik
  - Kullanıcı parametreleriyle kişiselleştirme
  - Tutarlı hikaye yapısı
  - Sayfalara kolay bölünebilecek format

- **Görsel üretimi** için prompt stratejileri:
  - Sayfa içeriğini analiz ederek anahtar elemanları çıkarma
  - Kullanıcı profilindeki fiziksel özellikleri dahil etme
  - Tutarlı sanat stili (storybook illustration style)
  - Krem rengi tonlarını vurgulama

### 5.3 İlerleme İzleme ve Geri Bildirim
- Adım adım ilerleme gösterimi:
  - Metin üretimi (% olarak)
  - Görsel üretimi (sayfa/toplam)
  - Ses oluşturma (sayfa/toplam)
- Animasyonlu durum geçişleri
- Hata durumlarını ele alma ve retry seçenekleri

## Aşama 6: Çoklu Cihaz ve Çevrimdışı Yetenekler

### 6.1 Çevrimdışı Erişim
- Favori masalları tam olarak yerel depolama:
  - Metin içeriği
  - Görseller
  - Ses dosyaları
- Bağlantı durumu tespiti
- Çevrimdışı durumda uygun bildirimler ve erişilebilir içerik

### 6.2 Cihazlar Arası Uyumluluk
- **Platform Bazlı Optimizasyonlar**:
  - iPad için yatay görünüm ve split-view desteği
  - iPhone için tek el kullanımına uygun arabirim
  - Web için responsive yapı ve yüklenme optimizasyonu

- **Farklı ekran boyutları** için esnek düzen:
  - MediaQuery kullanımı
  - Boyuta göre ölçeklenen komponetler
  - LayoutBuilder ile duyarlı düzen

### 6.3 Veri Senkronizasyonu
- JSON formatında dosya tabanlı içe/dışa aktarma:
  - Kullanıcı profillerini dışa aktarma
  - Favori masalları dışa aktarma
  - İçe aktarma ve çakışma çözümü

## Aşama 7: Test ve Optimizasyon

### 7.1 Test Stratejisi
- **Birim Testleri**:
  - API servisleri
  - Repository sınıfları
  - Veri modelleri
  - Utility fonksiyonları

- **Widget Testleri**:
  - Ortak UI bileşenleri
  - İnteraktif kontroller
  - Responsive tasarım özellikleri

- **Entegrasyon Testleri**:
  - Masal üretim iş akışı
  - Favoriler sistemi
  - Kullanıcı profil yönetimi

- **Platform Testleri**:
  - Web, iOS ve Android'de çapraz test
  - Farklı cihaz boyutları ile test

### 7.2 Performans Optimizasyonu
- **Görsel Optimizasyonu**:
  - Lazy loading (geciktirilmiş yükleme)
  - Önbellek stratejileri
  - Boyut optimizasyonu

- **Bellek Yönetimi**:
  - Büyük objeleri yönetme (görseller, ses dosyaları)
  - Akıllı önbellek temizleme
  - Kaynakları gerektiğinde serbest bırakma

- **Uygulama Başlangıç Süresi**:
  - Asenkron başlatma
  - Sıkıştırılmış assetler
  - Önbelleğe alma stratejileri

### 7.3 Hata Yönetimi ve Dayanıklılık
- **Kapsamlı Hata Yakalama**:
  - API hataları
  - Depolama hataları
  - UI hataları

- **Error Reporting**:
  - Detaylı hata günlükleri
  - Anlaşılır kullanıcı mesajları

- **Retry Mekanizmaları**:
  - API istekleri için
  - Kesintiye uğrayan indirmeler için
  - Başarısız görsel üretimleri için

## Aşama 8: Sonlandırma ve Dağıtım

### 8.1 Son UI İncelemesi
- Animasyonların ve geçişlerin incelenmesi
- Tüm platformlarda renk ve font tutarlılığı
- Kontrast ve erişilebilirlik kontrolü

### 8.2 Dokümantasyon
- Teknik dokümantasyon
- Kullanıcı kılavuzu
- API ve depolama dokümantasyonu

### 8.3 Platform Bazlı Dağıtım
- **iOS Dağıtımı**:
  - iPad ve iPhone için optimize edilmiş yapı
  - TestFlight ile test
  - Ad-Hoc dağıtım (aile içi kullanım için)

- **Android Dağıtımı**:
  - Signed APK oluşturma
  - Aile içi dağıtım

- **Web Dağıtımı**:
  - PWA yapılandırması
  - Hosting ve SSL sertifikası
  - Browser uyumluluk ayarları

## Teknik Gereksinim Detayları

### Proje Yapısı ve Organizasyon
```
lib/
├── core/
│   ├── api/
│   │   ├── network_service.dart
│   │   ├── gemini_api.dart
│   │   └── dalle_api.dart
│   ├── services/
│   │   ├── audio_service.dart
│   │   ├── storage_service.dart
│   │   ├── image_cache_service.dart
│   │   ├── download_manager.dart
│   │   └── logging_service.dart
│   └── utils/
│       ├── error_handler.dart
│       ├── result.dart
│       └── platform_utils.dart
├── data/
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── tale.dart
│   │   └── tale_page.dart
│   └── repositories/
│       ├── profile_repository.dart
│       ├── tale_repository.dart
│       └── favorites_repository.dart
├── ui/
│   ├── common/
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   ├── widgets/
│   │   │   ├── fable_button.dart
│   │   │   ├── whisper_loading_indicator.dart
│   │   │   ├── error_display.dart
│   │   │   ├── responsive_container.dart
│   │   │   ├── network_status_banner.dart
│   │   │   └── platform_aware_widget.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── select_profile_screen.dart
│   │   │   └── widgets/
│   │   │       └── profile_card.dart
│   │   ├── tale/
│   │   │   ├── tale_creation_screen.dart
│   │   │   ├── tale_viewer_screen.dart
│   │   │   └── widgets/
│   │   │       ├── book_page.dart
│   │   │       ├── audio_controls.dart
│   │   │       └── progress_indicator.dart
│   │   └── favorites/
│   │       ├── favorites_screen.dart
│   │       └── widgets/
│   │           ├── favorite_card.dart
│   │           └── download_status.dart
│   └── viewmodels/
│       ├── profile_viewmodel.dart
│       ├── tale_viewmodel.dart
│       ├── tale_generation_viewmodel.dart
│       └── favorites_viewmodel.dart
├── config/
│   ├── app_config.dart
│   ├── environment.dart
│   └── constants.dart
├── app.dart
└── main.dart

test/
├── core/
│   ├── api/
│   │   ├── network_service_test.dart
│   │   ├── gemini_api_test.dart
│   │   └── dalle_api_test.dart
│   └── services/
│       ├── audio_service_test.dart
│       ├── storage_service_test.dart
│       └── image_cache_service_test.dart
├── data/
│   ├── models/
│   │   ├── user_profile_test.dart
│   │   └── tale_test.dart
│   └── repositories/
│       ├── profile_repository_test.dart
│       ├── tale_repository_test.dart
│       └── favorites_repository_test.dart
├── ui/
│   ├── widgets/
│   │   ├── fable_button_test.dart
│   │   ├── responsive_container_test.dart
│   │   └── network_status_banner_test.dart
│   └── screens/
│       ├── tale_creation_screen_test.dart
│       └── tale_viewer_screen_test.dart
├── viewmodels/
│   ├── profile_viewmodel_test.dart
│   ├── tale_viewmodel_test.dart
│   └── favorites_viewmodel_test.dart
└── integration/
    ├── tale_creation_flow_test.dart
    ├── favorites_management_test.dart
    └── app_navigation_test.dart
```

### Renk Paleti ve Tipografi
```dart
// theme.dart

// Ana krem renk paleti
const Color mainBackgroundLight = Color(0xFFF5EFE6); // Çok açık krem (arka plan)
const Color mainBackgroundMedium = Color(0xFFEADDC7); // Açık krem (kart zeminleri)
const Color mainBackgroundDark = Color(0xFFD8C4A9);  // Orta krem (vurgu elementleri)

// Metin renkleri
const Color textPrimaryDark = Color(0xFF5E4D3B);  // Koyu kahverengi (ana metin)
const Color textSecondaryDark = Color(0xFF8D7B6A); // Orta kahverengi (ikincil metin)

// Buton renkleri
const Color buttonPrimaryActive = Color(0xFFD2B48C);   // Orta koyu krem (aktif buton)
const Color buttonPrimaryInactive = Color(0xFFE6D9C6); // Açık krem (inaktif buton)
const Color buttonTextDark = Color(0xFF4A3F35);        // Çok koyu kahve (buton metni)

// Kitap sayfası renkler
const Color bookPageBackground = Color(0xFFF7F0E6); // Çok açık krem (sayfa zemini)
const Color bookPageText = Color(0xFF3D3229);       // Çok koyu kahve (sayfa metni)

// Tipografi stil tanımları
const TextStyle headingStyle = TextStyle(
  fontFamily: 'Playfair',
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textPrimaryDark,
);

const TextStyle bodyStyle = TextStyle(
  fontFamily: 'Merriweather',
  fontSize: 16,
  color: textPrimaryDark, 
);

const TextStyle captionStyle = TextStyle(
  fontFamily: 'Merriweather',
  fontSize: 12,
  color: textSecondaryDark,
);

const TextStyle buttonStyle = TextStyle(
  fontFamily: 'Playfair',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: buttonTextDark,
);
```

### Masal Üretim Özellikleri
- Her masal şunlara göre üretilmelidir:
  - Kullanıcı profili (isim, cinsiyet, yaş, saç rengi, saç tipi, ten tonu)
  - Masal parametreleri (karakter, konum, tema)
  - Kelime sayısı (100-500 kelime)
- Her sayfada maksimum 50 kelime
- Her sayfanın ilgili görseli
- Sayfa içeriğiyle senkronize ses anlatımı

### Kullanıcı Profil Sistemi
- Maksimum 5 kullanıcı profili (kimlik doğrulama OLMADAN)
- Her profil için:
  - Temel bilgiler (isim, cinsiyet, yaş)
  - Fiziksel özellikler (saç rengi, saç tipi, ten tonu)
  - Oluşturma tarihi ve küçük resim (thumbnail)
- Silme/çıkarma butonu
- Cihazlar arası paylaşım seçeneği

### Favoriler Sistemi
- Maksimum 5 masal kaydedilebilir
- Her masalda tam içerik (metin, görseller, ses)
- Detaylı meta veriler
- Çevrimdışı erişim
- **Sadece favorilere eklenen masallar yerel olarak depolanacak**
- Silme butonu ve tarih/saat bilgisi

### UI Gereksinimleri
- Krem rengi tonları üzerine kurulu tasarım
- Her zaman koyu yazı/açık zemin kontrastı
- Platform özgü optimizasyonlar:
  - iPad: İki sayfa yan yana, grid görünümleri
  - iPhone: Kompakt düzen
  - Web: Responsive tasarım

## Önemli Dönüm Noktaları
1. Proje kurulumu ve mimari altyapı
2. Temel servisler ve veri modelleri
3. API entegrasyonu ve masal üretim iş akışı
4. Kullanıcı arayüzü temel bileşenleri
5. Kitap görünümü ve masal deneyimi
6. Favori ve çevrimdışı erişim yetenekleri
7. Çoklu platform desteği ve optimizasyonlar
8. Test, kalite kontrol ve dağıtım

Bu yol haritası, FableWhisper uygulamasını tüm gerekli özellikleriyle geliştirmek için kapsamlı ve dengeli bir rehber sağlar. Kod tabanı, bakım kolaylığı için yeterince modüler ancak gereksiz karmaşıklıktan kaçınılarak yapılandırılmıştır. iPad, iPhone ve Web platformlarında tutarlı bir deneyim sunulurken, her platformun güçlü yönlerinden yararlanacak optimizasyonlar yapılacaktır. Test yapısı kod tabanıyla paraleldir ve her seviyede test kapsamı sağlanmıştır.