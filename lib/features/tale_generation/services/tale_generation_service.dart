import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
      
      // Masal sayfalarını oluştur
      final List<TalePage> pages = [];
      
      for (int i = 0; i < pageContents.length; i++) {
        final content = pageContents[i];
        
        _updateProgress(
          'Sayfa ${i + 1} görseli oluşturuluyor...',
          0.4 + (0.5 * (i / pageContents.length)),
        );
        
        // Sayfa için görsel oluştur
        final String? imageBase64 = await _generatePageImage(
          content: content,
          theme: theme,
          setting: setting,
          userProfile: userProfile,
          pageIndex: i,
          forceRefresh: forceRefresh,
        );
        
        // Sayfayı ekle
        pages.add(TalePage(
          pageNumber: i + 1,  // Sayfa numarası ekledim
          content: content,
          imageBase64: imageBase64,
          // audioBase64 parametresi yok, audioPath kullanılıyor
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
      Başlık: "$title". 
      Tema: $themeText. 
      Ortam: $settingText. 
      Ana karakter: $characterDescription. 
      
      Önemli kurallar:
      1. Masal tam olarak $wordCount kelime içermeli, eksik kelime sayısıyla teslim etme
      2. Masal çocuklar için uygun, yaratıcı ve eğlenceli olmalı
      3. Masalı "SAYFA 1:", "SAYFA 2:" gibi başlıklarla bölme, tek bir metin olarak yaz
      4. Cümleler kısa ve anlaşılır olmalı
      5. Basit kelimeler kullan, karmaşık terimlerden kaçın
      6. Ana karakter, tema ve ortam tutarlı olmalı
      7. Açık bir giriş, gelişme ve sonuç kısmı olmalı
      8. Mutlaka tam olarak $wordCount kelime kullan, daha az değil
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
      // Tema ve ortam metinlerini al
      final themeText = _getThemeText(theme);
      final settingText = _getSettingText(setting);
      
      // Kullanıcı profilinden karakter bilgilerini al
      final String characterDescription = _generateCharacterDescription(userProfile);
      
      // Görsel oluşturma promptu
      final String prompt = '''
      Çocuk masalı için bir illüstrasyon oluştur. 
      Tema: $themeText. 
      Ortam: $settingText. 
      Ana karakter: $characterDescription. 
      Sayfa içeriği: "$content"
      Çocuklar için uygun, renkli ve detaylı bir illüstrasyon olmalı.
      ''';
      
      _logger.i('DALL-E API\'ye gönderilen prompt: $prompt');
      
      // DALL-E API'yi kullanarak görsel oluştur
      final String? base64Image = await _dalleApiService.generateImage(
        prompt: prompt,
        forceRefresh: forceRefresh,
      );
      
      return base64Image;
    } catch (e, stackTrace) {
      _logger.e('Sayfa görseli oluşturulurken hata: $e', stackTrace: stackTrace);
      return null;
    }
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
    
    // Her sayfaya düşecek cümle sayısını hesapla
    int sentencesPerPage = (sentences.length / targetPageCount).ceil();
    
    // Sayfaları oluştur
    List<String> pages = [];
    
    // İçeriği direkt kelime sayısına göre bölelim
    List<String> allWords = content.split(' ');
    int totalWords = allWords.length;
    
    _logger.i('Toplam kelime sayısı: $totalWords');
    
    // 300 kelimelik masalı 6 sayfaya bölmek için: 50 kelime/sayfa
    int wordsPerPage = 50; // Sabit olarak 50 kelime her sayfada
    
    // İçeriği kelime sayısına göre böl
    return _splitContentByWords(content, wordsPerPage);
  }
  
  /// Uzun sayfayı cümleleri bölmeden parçalara ayırır
  List<String> _splitLongPage(String pageContent) {
    List<String> words = pageContent.split(' ');
    int targetWordsPerPage = 45; // 45 kelime civarında
    
    List<String> pages = [];
    
    for (int i = 0; i < words.length; i += targetWordsPerPage) {
      int end = (i + targetWordsPerPage) > words.length ? words.length : i + targetWordsPerPage;
      String pagePart = words.sublist(i, end).join(' ');
      pages.add(pagePart);
    }
    
    return pages;
  }
  
  /// İçeriği kelime sayısına göre sayfalar halinde böler
  List<String> _splitContentByWords(String content, int wordsPerPage) {
    List<String> words = content.split(' ');
    List<String> pages = [];
    
    // 300 kelimelik masalı 6 sayfaya bölmek için: 50 kelime/sayfa
    // Varsayılan kelime sayısına göre sayfa başına düşecek kelime sayısını hesapla
    int adjustedWordsPerPage = 50; // Sabit sayfa başına 50 kelime

    _logger.i('Toplam ${words.length} kelime, sayfa başına $adjustedWordsPerPage kelime');
    
    for (int i = 0; i < words.length; i += adjustedWordsPerPage) {
      int end = (i + adjustedWordsPerPage) > words.length ? words.length : i + adjustedWordsPerPage;
      String page = words.sublist(i, end).join(' ');
      pages.add(page);
    }
    
    _logger.i('İçerik ${pages.length} sayfaya bölündü');
    return pages;
  }
  
  /// Cümleleri sayfalara gruplandırır
  List<String> _groupSentencesIntoPages(List<String> sentences, int targetWordsPerPage) {
    List<String> pages = [];
    String currentPage = '';
    int currentPageWordCount = 0;
    
    for (String sentence in sentences) {
      // Cümleyi temizle
      sentence = sentence.trim();
      if (sentence.isEmpty) continue;
      
      // Cümledeki kelime sayısı
      int sentenceWordCount = sentence.split(' ').length;
      
      // Eğer cümle çok uzunsa (bir sayfaya sığmayacak kadar), kelime kelime böl
      if (sentenceWordCount > targetWordsPerPage * 1.5) {
        if (currentPage.isNotEmpty) {
          pages.add(currentPage);
          currentPage = '';
          currentPageWordCount = 0;
        }
        
        // Uzun cümleyi kelimelerine ayır ve yeni sayfalar oluştur
        List<String> words = sentence.split(' ');
        for (int i = 0; i < words.length; i += targetWordsPerPage) {
          int end = (i + targetWordsPerPage) > words.length ? words.length : i + targetWordsPerPage;
          String pageContent = words.sublist(i, end).join(' ');
          pages.add(pageContent);
        }
        continue;
      }
      
      // Eğer mevcut sayfa + yeni cümle hedef kelime sayısını aşıyorsa, yeni sayfa başlat
      if (currentPageWordCount + sentenceWordCount > targetWordsPerPage) {
        if (currentPage.isNotEmpty) {
          pages.add(currentPage);
          currentPage = sentence;
          currentPageWordCount = sentenceWordCount;
        } else {
          // Eğer mevcut sayfa boşsa, cümleyi ekle
          currentPage = sentence;
          currentPageWordCount = sentenceWordCount;
        }
      } else {
        // Mevcut sayfaya cümleyi ekle
        if (currentPage.isNotEmpty) {
          currentPage += ' ' + sentence;
        } else {
          currentPage = sentence;
        }
        currentPageWordCount += sentenceWordCount;
      }
    }
    
    // Son sayfayı ekle
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }
    
    _logger.i('Cümlelerden ${pages.length} sayfa oluşturuldu');
    return pages;
  }
  
  /// Masal promptu oluşturur.
  String _createTalePrompt({
    required String title,
    required String theme,
    required String setting,
    required int wordCount,
    required UserProfile userProfile,
  }) {
    return '''
    Lütfen "${title}" başlıklı, ${wordCount} kelimelik bir çocuk masalı oluştur.
    
    Masal şu temayı içermeli: ${theme}
    Masal şu ortamda geçmeli: ${setting}
    
    Masal, ana karakter olarak şu özelliklere sahip bir çocuğu içermeli:
    - İsim: ${userProfile.name}
    - Yaş: ${userProfile.age}
    - Cinsiyet: ${userProfile.genderText}
    - Saç rengi: ${userProfile.hairColorText}
    - Saç tipi: ${userProfile.hairTypeText}
    - Ten rengi: ${userProfile.skinToneText}
    
    Masal, ${userProfile.age} yaşındaki bir çocuğun anlayabileceği dilde olmalı.
    Masal, olumlu değerler ve öğretici mesajlar içermeli.
    Masal, yaratıcı ve ilgi çekici olmalı.
    Masal, giriş, gelişme ve sonuç bölümlerini içermeli.
    
    Lütfen sadece masal metnini döndür, başka açıklama ekleme.
    ''';
  }
  
  /// Görsel promptu oluşturur.
  String _createImagePrompt({
    required String content,
    required String theme,
    required String setting,
    required UserProfile userProfile,
    required int pageIndex,
  }) {
    return '''
    Bir çocuk kitabı için ${setting} ortamında geçen, ${theme} temalı bir illüstrasyon.
    
    Ana karakter şu özelliklere sahip bir çocuk:
    - İsim: ${userProfile.name}
    - Yaş: ${userProfile.age}
    - Cinsiyet: ${userProfile.genderText}
    - Saç rengi: ${userProfile.hairColorText}
    - Saç tipi: ${userProfile.hairTypeText}
    - Ten rengi: ${userProfile.skinToneText}
    
    Sayfada şu içerik anlatılıyor: ${content}
    
    Tarz: Sıcak, renkli, çocuk dostu, detaylı, dijital çizim.
    Görsel, antik bir kitap sayfasında yer alacak şekilde tasarlanmalı.
    ''';
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
  
  /// Gemini API yanıtını sayfalara böler.
  List<String> _extractPagesFromResponse(String response) {
    try {
      _logger.d('API yanıtından sayfalar çıkarılıyor');
      
      // Yanıtı sayfalara ayır
      List<String> pages = [];
      
      // "SAYFA X:" deseniyle bölmeyi dene
      if (response.contains('SAYFA')) {
        final pageMatches = RegExp(r'SAYFA \d+:(.+?)(?=SAYFA \d+:|$)', dotAll: true)
            .allMatches(response)
            .map((match) => match.group(1)?.trim() ?? '')
            .where((text) => text.isNotEmpty)
            .toList();
            
        if (pageMatches.isNotEmpty) {
          pages = pageMatches;
          _logger.i('${pages.length} sayfa bulundu (SAYFA X: formatı)');
        }
      }
      
      // Eğer sayfa bulunamadıysa, tüm içeriği al ve _splitContentIntoPages metodunu kullan
      if (pages.isEmpty) {
        _logger.w('Sayfa formatı bulunamadı, içerik manuel olarak bölünüyor');
        
        // Telif metin gibi anahtar ifadeleri kaldır
        final cleanedResponse = response
            .replaceAll(RegExp(r'^\s*\*\*.*?\*\*\s*', multiLine: true), '')  // ** başlıkları kaldır
            .replaceAll(RegExp(r'^\s*#.*?#\s*', multiLine: true), '')     // # başlıkları kaldır
            .trim();
            
        pages = _splitContentIntoPages(cleanedResponse, 300); // Varsayılan 300 kelime
        _logger.i('İçerik manuel olarak ${pages.length} sayfaya bölündü');
      }
      
      // Sayfa sayısı kontrolü - çok fazla veya çok az sayfa varsa düzelt
      if (pages.length > 15 || pages.length < 3) {
        _logger.w('Sayfa sayısı düzeltiliyor: ${pages.length}');
        final allContent = pages.join(' ');
        pages = _splitContentIntoPages(allContent, 300);  // 300 kelimelik varsayılan masal
        _logger.i('Sayfa sayısı ${pages.length} olarak ayarlandı');
      }
      
      return pages;
    } catch (e, stackTrace) {
      _logger.e('Sayfalar çıkarılırken hata oluştu: $e', stackTrace: stackTrace);
      // Hata durumunda boş bir örnek sayfa döndür
      return ['Bir varmış bir yokmuş...'];
    }
  }
}
