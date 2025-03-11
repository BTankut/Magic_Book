import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart' show TaleTheme, TaleSetting;
import 'package:magic_book/features/tale_generation/services/tale_generation_service.dart';
import 'package:magic_book/features/tale_viewer/screens/tale_viewer_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Masal üretim ekranı.
/// 
/// Bu ekran, kullanıcının seçtiği özelliklere göre masal içeriğini ve görselleri oluşturur.
class TaleGenerationScreen extends StatefulWidget {
  /// Masal başlığı.
  final String title;
  
  /// Masal teması.
  final TaleTheme theme;
  
  /// Masal ortamı.
  final TaleSetting setting;
  
  /// Masal kelime sayısı.
  final int wordCount;
  
  /// Kullanıcı profili.
  final UserProfile userProfile;
  
  /// Önbelleği temizleyerek yeni içerik oluşturma.
  final bool forceRefresh;

  const TaleGenerationScreen({
    super.key,
    required this.title,
    required this.theme,
    required this.setting,
    required this.wordCount,
    required this.userProfile,
    this.forceRefresh = false,
  });

  @override
  State<TaleGenerationScreen> createState() => _TaleGenerationScreenState();
}

class _TaleGenerationScreenState extends State<TaleGenerationScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  final TaleGenerationService _taleGenerationService = getIt<TaleGenerationService>();
  
  bool _isGenerating = true;
  String _statusMessage = 'Masal oluşturuluyor...';
  double _progress = 0.0;
  
  Tale? _generatedTale;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _generateTale();
  }
  
  /// Masal içeriğini ve görselleri oluşturur.
  Future<void> _generateTale() async {
    try {
      // Masal oluşturma işlemi başlatıldı
      _logger.i('Masal oluşturma işlemi başlatıldı: ${widget.title}');
      
      // İlerleme durumunu dinle
      _taleGenerationService.onProgressUpdate = (message, progress) {
        setState(() {
          _statusMessage = message;
          _progress = progress;
        });
      };
      
      // Masal oluştur
      final generatedTale = await _taleGenerationService.generateTale(
        title: widget.title,
        theme: widget.theme,
        setting: widget.setting,
        wordCount: widget.wordCount,
        userProfile: widget.userProfile,
        forceRefresh: widget.forceRefresh,
      );
      
      // Tale model sınıfını shared/models/tale.dart içindeki Tale sınıfına dönüştür
      final tale = Tale(
        id: generatedTale.id,
        title: generatedTale.title,
        theme: generatedTale.theme.toString().split('.').last,
        setting: generatedTale.setting.toString().split('.').last,
        wordCount: generatedTale.wordCount,
        userId: widget.userProfile.id,
        pages: generatedTale.pages.map((page) => TalePage(
          id: page.id,
          pageNumber: page.pageNumber,
          content: page.content,
          imageBase64: page.imageBase64,
          audioPath: page.audioPath,
        )).toList(),
        createdAt: generatedTale.createdAt,
        isFavorite: true,
      );
      
      // Masalı kaydet
      await _storageService.saveFavoriteTale(tale);
      
      setState(() {
        _generatedTale = tale;
        _isGenerating = false;
        _progress = 1.0;
      });
      
      _logger.i('Masal başarıyla oluşturuldu: ${tale.id}');
    } catch (e, stackTrace) {
      _logger.e('Masal oluşturulurken hata oluştu', error: e, stackTrace: stackTrace);
      
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Masal oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.';
      });
    }
  }
  
  // Bu metot kullanılmıyor, yeni sürümde tale_generation_service içinden metin üretiliyor
  /*
  /// Örnek masal sayfaları oluşturur.
  List<String> _generateDummyPageContents() {
    // Gerçek uygulamada bu içerik Gemini API'den gelecek
    final List<String> contents = [];
    
    // Tema ve ortama göre bir hikaye oluştur
    final String themeText = _getThemeText(widget.theme);
    final String settingText = _getSettingText(widget.setting);
    
    // Karakter bilgilerini al
    final String characterName = widget.userProfile.name;
    final int characterAge = widget.userProfile.age;
    final String genderText = widget.userProfile.genderText;
    
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
  */
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masal Oluşturuluyor'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textLightColor,
        elevation: 2,
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isGenerating
                ? _buildGeneratingContent()
                : _errorMessage != null
                    ? _buildErrorContent()
                    : _buildSuccessContent(),
          ),
        ),
      ),
    );
  }
  
  /// Masal oluşturulurken gösterilecek içerik.
  Widget _buildGeneratingContent() {
    // İlerleme durumuna göre gösterilecek simgeyi belirle
    Widget progressIcon;
    if (_progress < 0.4) {
      // Metin oluşturma aşaması
      progressIcon = const Icon(
        Icons.auto_fix_high,
        size: 100,
        color: AppTheme.primaryColor,
      );
    } else if (_progress < 0.9) {
      // Görsel oluşturma aşaması
      progressIcon = const Icon(
        Icons.image,
        size: 100,
        color: AppTheme.primaryColor,
      );
    } else {
      // Tamamlanma aşaması
      progressIcon = const Icon(
        Icons.book,
        size: 100,
        color: AppTheme.primaryColor,
      );
    }
    
    // İlerleme durumuna göre aşama bilgisi
    String phaseInfo = "";
    if (_progress < 0.3) {
      phaseInfo = "Masal metni oluşturuluyor";
    } else if (_progress < 0.4) {
      phaseInfo = "Masal sayfaları hazırlanıyor";
    } else if (_progress < 0.9) {
      phaseInfo = "Görseller üretiliyor";
    } else {
      phaseInfo = "Masal tamamlanıyor";
    }
    
    return Center(
      child: Card(
        elevation: 4,
        color: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: AppTheme.primaryLightColor,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              progressIcon,
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                phaseInfo,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: 300,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.primaryLightColor),
                ),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.primaryLightColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'İlerleme: ${(_progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Hikayeniz ve görseller AI ile oluşturuluyor.\nBu işlem 20-30 saniye sürebilir.',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Hata durumunda gösterilecek içerik.
  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Bir Hata Oluştu',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Bilinmeyen bir hata oluştu.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AntiqueButton(
            text: 'Tekrar Dene',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _isGenerating = true;
                _errorMessage = null;
                _progress = 0.0;
              });
              _generateTale();
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }
  
  /// Başarılı durumda gösterilecek içerik.
  Widget _buildSuccessContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'Masalınız Hazır!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Masalınız başarıyla oluşturuldu. Şimdi masalınızı okumaya başlayabilirsiniz.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AntiqueButton(
            text: 'Masalı Oku',
            icon: Icons.book,
            onPressed: () {
              if (_generatedTale != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaleViewerScreen(
                      taleId: _generatedTale!.id,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ana Sayfaya Dön'),
          ),
        ],
      ),
    );
  }
}
