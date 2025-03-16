import 'package:magic_book/core/services/dalle_api_service.dart';
import 'package:magic_book/core/services/gemini_api_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart' show TaleTheme, TaleSetting;
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/models/user_profile.dart';

/// Masal üretim servisi.
/// 
/// Bu servis, Gemini API'yi kullanarak masal içeriği oluşturur ve DALL-E API'yi kullanarak görseller üretir.
class TaleGenerationService {
  final GeminiApiService _geminiApiService;
  final DalleApiService _dalleApiService;
  final LoggingService _logger;
  
  /// Varsayılan constructor.
  TaleGenerationService() : 
    _geminiApiService = getIt<GeminiApiService>(),
    _dalleApiService = getIt<DalleApiService>(),
    _logger = getIt<LoggingService>();
  
  /// Test için constructor.
  TaleGenerationService.withDependencies(
    this._geminiApiService,
    this._dalleApiService,
    this._logger,
  );
  
  /// Masal üretim durumunu dinleyen fonksiyon.
  Function(String message, double progress)? onProgressUpdate;
  
  /// Masal üretir.
  /// 
  /// [title] Masal başlığı.
  /// [theme] Masal teması.
  /// [setting] Masal ortamı.
  /// [wordCount] Masal kelime sayısı.
  /// [userProfile] Kullanıcı profili.
  /// [forceRefresh] Önbelleği temizleyerek yeni içerik oluşturma.
  Future<Tale> generateTale({
    required String title,
    required TaleTheme theme,
    required TaleSetting setting,
    required int wordCount,
    required UserProfile userProfile,
    bool forceRefresh = false,
  }) async {
    try {
      _updateProgress('Masal içeriği oluşturuluyor...', 0.1);
      
      // Masal içeriğini oluştur
      final List<String> pageContents = await _generateTaleContent(
        title: title,
        theme: theme,
        setting: setting,
        wordCount: wordCount,
        userProfile: userProfile,
        forceRefresh: forceRefresh,
      );
      
      _updateProgress('Masal görselleri oluşturuluyor...', 0.4);
      
      // Masal sayfaları için görselleri paralel olarak oluştur
      final List<Future<String?>> imageFutures = [];
      
      for (int i = 0; i < pageContents.length; i++) {
        _updateProgress(
          'Sayfa ${i + 1} görseli talep ediliyor...',
          0.4 + (0.1 * (i / pageContents.length)),
        );
        
        // Sayfa için görsel talebini kuyruğa ekle
        imageFutures.add(_generatePageImage(
          content: pageContents[i],
          theme: theme,
          setting: setting,
          userProfile: userProfile,
          pageIndex: i,
          forceRefresh: forceRefresh,
        ));
      }
      
      _updateProgress('Görseller işleniyor...', 0.5);
      
      // Tüm görsel taleplerinin tamamlanmasını bekle
      final List<String?> images = await Future.wait(imageFutures);
      
      _updateProgress('Masal sayfaları oluşturuluyor...', 0.8);
      
      // Masal sayfalarını oluştur
      final List<TalePage> pages = [];
      
      for (int i = 0; i < pageContents.length; i++) {
        // Sayfayı ekle
        pages.add(TalePage(
          pageNumber: i + 1,
          content: pageContents[i],
          imageBase64: images[i],
        ));
      }
      
      _updateProgress('Masal tamamlanıyor...', 0.95);
      
      // Masal nesnesini oluştur
      final tale = Tale(
        title: title,
        theme: theme.toString().split('.').last,
        setting: setting.toString().split('.').last,
        wordCount: wordCount,
        pages: pages,
        userId: userProfile.id,
        createdAt: DateTime.now(),
        isFavorite: false,
      );
      
      _updateProgress('Masal başarıyla oluşturuldu!', 1.0);
      
      return tale;
    } catch (e, stackTrace) {
      _logger.e('Masal üretilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Masal içeriği oluşturur.
  Future<List<String>> _generateTaleContent({
    required String title,
    required TaleTheme theme,
    required TaleSetting setting,
    required int wordCount,
    required UserProfile userProfile,
    bool forceRefresh = false,
  }) async {
    try {
      // Tema ve ortam metinlerini al
      final themeText = _getThemeText(theme);
      final settingText = _getSettingText(setting);
      
      // Kullanıcı profilinden karakter bilgilerini al
      final String characterDescription = _generateCharacterDescription(userProfile);
      
      // Masal oluşturma promptu
      final String prompt = '''
      Bana bir çocuk masalı yaz. 
      Tema: $themeText. 
      Ortam: $settingText. 
      Ana karakter: $characterDescription. 
      
      Önemli kurallar:
      1. Masal tam olarak $wordCount kelime içermeli, eksik kelime sayısıyla teslim etme
      2. Masal çocuklar için uygun, yaratıcı ve eğlenceli olmalı
      3. Masalı DÜZENLEYEN İŞARETLER KULLANMADAN tek bir metin olarak yaz - başlık, sayfa numarası veya bölüm işaretleri KOYMA
      4. Cümleler kısa ve anlaşılır olmalı
      5. Basit kelimeler kullan, karmaşık terimlerden kaçın
      6. Ana karakter, tema ve ortam tutarlı olmalı
      7. Açık bir giriş, gelişme ve sonuç kısmı olmalı
      8. Mutlaka tam olarak $wordCount kelime kullan, daha az değil
      9. Yanıtında SADECE masal metnini gönder, başka açıklama veya metin ekleme
      ''';
      
      _logger.i('Gemini API\'ye gönderilen prompt: $prompt');
      
      // Gemini API'yi kullanarak masal içeriği oluştur
      final String response = await _geminiApiService.generateText(
        prompt: prompt,
        forceRefresh: forceRefresh,
      );
      
      _logger.i('Gemini API yanıtı: $response');
      
      // Yanıtı sayfalara böl
      final List<String> pages = _extractPagesFromResponse(response);
      
      return pages;
    } catch (e, stackTrace) {
      _logger.e('Masal içeriği oluşturulurken hata: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Sayfa görseli oluşturur.
  Future<String?> _generatePageImage({
    required String content,
    required TaleTheme theme,
    required TaleSetting setting,
    required UserProfile userProfile,
    required int pageIndex,
    bool forceRefresh = false,
  }) async {
    try {
      // Görsel promptu oluştur
      final String prompt = _createImagePrompt(
        content: content,
        theme: _getThemeText(theme),
        setting: _getSettingText(setting),
        userProfile: userProfile,
        pageIndex: pageIndex,
      );
      
      _logger.i('DALL-E API\'ye gönderilen prompt (sayfa ${pageIndex + 1}): $prompt');
      
      // DALL-E API'yi kullanarak görsel oluştur
      final String? base64Image = await _dalleApiService.generateImage(
        prompt: prompt,
        forceRefresh: forceRefresh,
      );
      
      if (base64Image != null) {
        _logger.i('Sayfa ${pageIndex + 1} görseli başarıyla oluşturuldu');
      } else {
        _logger.w('Sayfa ${pageIndex + 1} görseli oluşturulamadı');
      }
      
      return base64Image;
    } catch (e, stackTrace) {
      _logger.e('Sayfa ${pageIndex + 1} görseli oluşturulurken hata: $e', stackTrace: stackTrace);
      
      // Prompt içerik politikası sorunu olabilir, daha basit bir prompt ile tekrar dene
      if (e.toString().contains('content_policy_violation') || 
          e.toString().contains('İçerik politikası ihlali') ||
          e.toString().contains('400')) {
        try {
          _logger.w('Sayfa ${pageIndex + 1} için basitleştirilmiş promptla tekrar deneniyor');
          
          // Basitleştirilmiş prompt
          final String simplifiedPrompt = _createSimplifiedImagePrompt(
            theme: _getThemeText(theme),
            setting: _getSettingText(setting),
          );
          
          _logger.i('DALL-E API\'ye basitleştirilmiş prompt gönderiliyor: $simplifiedPrompt');
          
          // DALL-E API'yi basitleştirilmiş promptla kullanarak görsel oluştur
          return await _dalleApiService.generateImage(
            prompt: simplifiedPrompt,
            forceRefresh: true, // Önbelleği kullanmamak için
          );
        } catch (retryError, retryStackTrace) {
          _logger.e('Basitleştirilmiş promptla da hata oluştu', error: retryError, stackTrace: retryStackTrace);
          return null;
        }
      }
      return null;
    }
  }
  
  /// Basitleştirilmiş görsel promptu (içerik politikası sorunlarını önlemek için).
  String _createSimplifiedImagePrompt({
    required String theme,
    required String setting,
  }) {
    return 'Bir çocuk kitabı için $setting ortamında geçen, $theme temalı bir illüstrasyon. '
           'Tarz: Sıcak, renkli, çocuk dostu. '
           'Hiçbir yazı veya metin içermemelidir.';
  }
  
  /// Görsel promptu oluşturur.
  String _createImagePrompt({
    required String content,
    required String theme,
    required String setting,
    required UserProfile userProfile,
    required int pageIndex,
  }) {
    // Kısa ve öz bir prompt oluştur
    return 'Bir çocuk kitabı için $setting ortamında geçen, $theme temalı, ${userProfile.genderText} bir çocuğun hikayesini anlatan bir illüstrasyon. '
           'Karakter özellikleri: ${userProfile.name}, ${userProfile.age} yaşında, ${userProfile.hairColorText} saçlı, '
           '${userProfile.hairTypeText} saçlı, ${userProfile.skinToneText} tenli. '
           'Sahne içeriği: $content. '
           'Tarz: Sıcak, renkli, çocuk dostu, dijital çizim. '
           'Görsel modern bir çocuk kitabı tarzında olmalı ve kesinlikle hiçbir yazı içermemelidir.';
  }
  
  /// Masal içeriğini sayfalara böler.
  List<String> _splitContentIntoPages(String content, int totalWordCount) {
    // İçeriği temizle - fazla boşlukları kaldır
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Cümlelere ayır
    List<String> sentences = content.split(RegExp(r'(?<=[.!?])\s+'));
    
    // Boş cümleleri filtrele
    sentences = sentences.where((s) => s.trim().isNotEmpty).toList();
    
    _logger.i('Toplam ${sentences.length} cümle bulundu');
    
    // Maksimum sayfa sayısını belirle
    int targetPageCount = (totalWordCount / 30).ceil();
    targetPageCount = targetPageCount.clamp(6, 15);
    
    // Her sayfaya düşecek cümle sayısını hesapla - şu anda doğrudan kelime bazlı bölme yapıyoruz
    // int sentencesPerPage = (sentences.length / targetPageCount).ceil();
    
    // Sayfaları oluştur - doğrudan kelime bazlı bölme yapıyoruz
    // List<String> pages = [];
    
    // İçeriği direkt kelime sayısına göre bölelim
    List<String> allWords = content.split(' ');
    int totalWords = allWords.length;
    
    _logger.i('Toplam kelime sayısı: $totalWords');
    
    // 300 kelimelik masalı 6 sayfaya bölmek için: 50 kelime/sayfa
    int wordsPerPage = 50; // Sabit olarak 50 kelime her sayfada
    
    // İçeriği kelime sayısına göre böl
    return _splitContentByWords(content, wordsPerPage);
  }
  
  /// İçeriği kelime sayısına göre sayfalar halinde böler
  List<String> _splitContentByWords(String content, int wordsPerPage) {
    List<String> words = content.split(' ');
    List<String> pages = [];
    
    // Toplam kelime sayısı
    int totalWords = words.length;
    
    // Standart sayfalama ile sayfa sayısını hesapla
    int pageCount = (totalWords / wordsPerPage).ceil();
    
    // Son sayfaya düşecek kelime sayısını kontrol et
    int remainingWords = totalWords % wordsPerPage;
    int minimumLastPageWords = 40; // Son sayfada olması gereken minimum kelime sayısı
    
    // Eğer son sayfadaki kelime sayısı minimum değerden azsa ve birden fazla sayfa varsa
    if (remainingWords > 0 && remainingWords < minimumLastPageWords && pageCount > 1) {
      _logger.i('Son sayfada $remainingWords kelime var, minimum $minimumLastPageWords\'dan az olduğu için yeniden düzenleniyor');
      
      // Kelimeleri diğer sayfalara dağıt
      // Sayfa sayısını bir azalt (son sayfayı kaldır)
      pageCount -= 1;
      
      // Her sayfaya eklenecek ek kelime sayısını hesapla
      int extraWordsPerPage = (remainingWords / pageCount).ceil();
      
      // Yeni sayfa başına düşecek kelime sayısı
      int newWordsPerPage = wordsPerPage + extraWordsPerPage;
      
      _logger.i('Yeni düzenleme: $pageCount sayfa, sayfa başına yaklaşık $newWordsPerPage kelime');
      
      // Yeni sayfalama yap
      for (int i = 0; i < totalWords; i += newWordsPerPage) {
        int end = (i + newWordsPerPage) > totalWords ? totalWords : i + newWordsPerPage;
        String page = words.sublist(i, end).join(' ');
        pages.add(page);
        
        // Son sayfa için kelime sayısını ayarla (son sayfa öncekilerden farklı olabilir)
        if (pages.length == pageCount - 1 && end < totalWords) {
          page = words.sublist(end).join(' ');
          pages.add(page);
          break;
        }
      }
    } else {
      // Standart sayfalama yap
      int adjustedWordsPerPage = wordsPerPage; // Sabit sayfa başına kelime sayısı
      
      _logger.i('Toplam ${words.length} kelime, sayfa başına $adjustedWordsPerPage kelime');
      
      for (int i = 0; i < words.length; i += adjustedWordsPerPage) {
        int end = (i + adjustedWordsPerPage) > words.length ? words.length : i + adjustedWordsPerPage;
        String page = words.sublist(i, end).join(' ');
        pages.add(page);
      }
    }
    
    _logger.i('İçerik ${pages.length} sayfaya bölündü');
    return pages;
  }
  
  /// Gemini API yanıtını sayfalara böler.
  List<String> _extractPagesFromResponse(String response) {
    try {
      _logger.d('API yanıtından masal içeriği işleniyor');
      
      // Telif metni gibi anahtar ifadeleri ve gereksiz boşlukları kaldır
      final cleanedResponse = response
          .replaceAll(RegExp(r'^\s*\*\*.*?\*\*\s*', multiLine: true), '')  // ** başlıkları kaldır
          .replaceAll(RegExp(r'^\s*#.*?#\s*', multiLine: true), '')     // # başlıkları kaldır
          .replaceAll(RegExp(r'SAYFA \d+:', caseSensitive: false), '')  // Olası sayfa işaretlerini kaldır
          .replaceAll(RegExp(r'\s+'), ' ')  // Fazla boşlukları tek boşluğa indir
          .trim();
      
      _logger.i('Masal içeriği temizlendi, kelime sayısı: ${cleanedResponse.split(' ').length}');
      
      // İçeriği sayfalar halinde böl
      List<String> pages = _splitContentIntoPages(cleanedResponse, 300); // Varsayılan 300 kelime
      _logger.i('İçerik ${pages.length} sayfaya bölündü');
      
      // Sayfa sayısı kontrolü - çok fazla veya çok az sayfa varsa düzelt
      if (pages.length > 15 || pages.length < 3) {
        _logger.w('Sayfa sayısı sınırlar dışında: ${pages.length} - düzeltiliyor');
        
        // İçeriği tekrar böl, farklı kelime sayısı hedefiyle
        int targetWordCount = (pages.length > 15) ? 500 : 200;
        pages = _splitContentIntoPages(cleanedResponse, targetWordCount);
        
        _logger.i('İçerik yeniden bölündü, yeni sayfa sayısı: ${pages.length}');
      }
      
      return pages;
    } catch (e, stackTrace) {
      _logger.e('İçerik sayfalara bölünürken hata: $e', stackTrace: stackTrace);
      return [response]; // Hata durumunda tüm içeriği tek sayfa olarak döndür
    }
  }
  
  /// İlerleme durumunu günceller.
  void _updateProgress(String message, double progress) {
    if (onProgressUpdate != null) {
      onProgressUpdate!(message, progress);
    }
  }
  
  /// Tema adını döndürür.
  String _getThemeText(TaleTheme theme) {
    switch (theme) {
      case TaleTheme.adventure:
        return 'Macera';
      case TaleTheme.fantasy:
        return 'Fantastik';
      case TaleTheme.friendship:
        return 'Arkadaşlık';
      case TaleTheme.nature:
        return 'Doğa';
      case TaleTheme.space:
        return 'Uzay';
      case TaleTheme.animals:
        return 'Hayvanlar';
      case TaleTheme.magic:
        return 'Sihir';
      case TaleTheme.heroes:
        return 'Kahramanlar';
    }
  }
  
  /// Ortam adını döndürür.
  String _getSettingText(TaleSetting setting) {
    switch (setting) {
      case TaleSetting.forest:
        return 'Orman';
      case TaleSetting.castle:
        return 'Şato';
      case TaleSetting.space:
        return 'Uzay';
      case TaleSetting.ocean:
        return 'Okyanus';
      case TaleSetting.mountain:
        return 'Dağ';
      case TaleSetting.city:
        return 'Şehir';
      case TaleSetting.village:
        return 'Köy';
      case TaleSetting.island:
        return 'Ada';
      case TaleSetting.desert:
        return 'Çöl';
      case TaleSetting.rainforest:
        return 'Yağmur Ormanı';
    }
  }
  
  /// Örnek masal sayfaları oluşturur.
  List<String> _generateDummyPageContents({
    required TaleTheme theme,
    required TaleSetting setting,
    required UserProfile userProfile,
  }) {
    // Gerçek uygulamada bu içerik Gemini API'den gelecek
    final List<String> contents = [];
    
    // Tema ve ortama göre bir hikaye oluştur
    final String themeText = _getThemeText(theme);
    final String settingText = _getSettingText(setting);
    
    // Karakter bilgilerini al
    final String characterName = userProfile.name;
    final int characterAge = userProfile.age;
    final String genderText = userProfile.genderText;
    
    // Giriş sayfası
    contents.add(
      'Bir varmış bir yokmuş, $settingText\'da yaşayan $characterAge yaşında bir $genderText varmış. '
      'Bu $genderText\'ın adı $characterName\'miş. $characterName çok meraklı ve maceracı bir çocukmuş.'
    );
    
    // Gelişme sayfaları
    contents.add(
      'Bir gün $characterName, $settingText\'da dolaşırken ilginç bir şey keşfetmiş. '
      'Bu keşif onu büyük bir $themeText macerasına sürüklemiş.'
    );
    
    contents.add(
      '$characterName, bu macerada birçok zorlukla karşılaşmış. '
      'Ama cesareti ve zekası sayesinde tüm zorlukların üstesinden gelmiş.'
    );
    
    // Sonuç sayfası
    contents.add(
      'Sonunda $characterName, macerasını başarıyla tamamlamış ve evine dönmüş. '
      'Bu maceradan çok şey öğrenmiş ve artık daha güçlü bir çocuk olmuş. '
      'Ve sonsuza dek mutlu yaşamışlar.'
    );
    
    return contents;
  }
  
  /// Kullanıcı profilinden karakter bilgilerini oluşturur.
  String _generateCharacterDescription(UserProfile userProfile) {
    return '${userProfile.name}, ${userProfile.age} yaşında, ${userProfile.genderText}, '
    '${userProfile.hairColorText} saçlı, ${userProfile.hairTypeText} saçlı, '
    '${userProfile.skinToneText} tenli.';
  }
}
