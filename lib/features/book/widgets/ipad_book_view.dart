import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:page_flip_builder/page_flip_builder.dart';
import 'package:magic_book/shared/utils/device_utils.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/theme/app_theme.dart';

/// iPad için özel kitap görünümü
/// 
/// Bu widget, iPad'in daha geniş ekranında iki sayfayı yan yana gösterir.
/// Yatay modda daha etkili bir deneyim sunar.
class IPadBookView extends StatefulWidget {
  final Tale tale;
  final Function(int) onPageChanged;
  final Function? onAudioToggle;
  final int initialPage;
  final bool isPlaying;

  const IPadBookView({
    super.key,
    required this.tale,
    required this.onPageChanged,
    this.onAudioToggle,
    this.initialPage = 0,
    this.isPlaying = false,
  });

  @override
  State<IPadBookView> createState() => _IPadBookViewState();
}

class _IPadBookViewState extends State<IPadBookView> with WidgetsBindingObserver {
  late int _currentPageIndex;
  final _pageKey = GlobalKey();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
    
    // Widget oluşturulduktan sonra hazır olduğunu işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
    
    // Ekran yönü değişikliklerini dinle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Ekran yönü değiştiğinde sayfayı yeniden oluştur
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hazır değilse yükleniyor göster
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return _buildCustomPageView();
  }
  
  Widget _buildCustomPageView() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Stack(
      children: [
        // Ana içerik
        _buildSinglePage(_currentPageIndex),
        
        // Sayfa geçiş butonları (sadece yan butonları göster, alt butonları kaldır)
        if (_currentPageIndex > 0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _navigateToPage(_currentPageIndex - 1),
                child: Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        
        if (_currentPageIndex < widget.tale.pages.length - 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _navigateToPage(_currentPageIndex + 1),
                child: Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
          
        // Alt bilgi çubuğu
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seslendirme butonu
                  GestureDetector(
                    onTap: () {
                      // Seslendirme işlevini TaleViewerScreen'e bildir
                      if (widget.onAudioToggle != null) {
                        widget.onAudioToggle!();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isPlaying ? Icons.stop : Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Sayfa numarası
                  Text(
                    '${_currentPageIndex + 1} / ${widget.tale.pages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _navigateToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= widget.tale.pages.length) {
      debugPrint('Geçersiz sayfa indeksi: $pageIndex (toplam sayfa: ${widget.tale.pages.length})');
      return;
    }
    
    debugPrint('IPadBookView: Sayfa değiştiriliyor - Şu anki: $_currentPageIndex, Hedef: $pageIndex');
    
    if (mounted) {
      setState(() {
        _currentPageIndex = pageIndex;
      });
      
      // Callback'i çağır ve debug mesajı ekle
      widget.onPageChanged(pageIndex);
      debugPrint('IPadBookView: Sayfa başarıyla değiştirildi: $_currentPageIndex');
    } else {
      debugPrint('IPadBookView: Widget mounted değil, sayfa değiştirilemedi');
    }
  }
  
  /// Tek bir kitap sayfası
  Widget _buildSinglePage(int index) {
    if (index >= widget.tale.pages.length) {
      return const SizedBox();
    }
    
    final page = widget.tale.pages[index];
    final orientation = DeviceUtils.getDeviceOrientation(context);
    final isLandscape = orientation == DeviceOrientation.landscape;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: isLandscape 
          ? _buildLandscapePageContent(page, index)  // Yatay mod için özel düzen
          : _buildPortraitPageContent(page, index),  // Dikey mod için mevcut düzen
    );
  }
  
  /// Yatay mod için sayfa içeriği (sol: metin, sağ: resim)
  Widget _buildLandscapePageContent(TalePage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sol taraf: Metin
          Expanded(
            flex: 1,
            child: Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
              ),
              color: AppTheme.backgroundColor, // Bej rengi (0xFFF5F5DC)
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Text(
                      page.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        fontSize: 24.0, // iPad için daha büyük font
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Sağ taraf: Resim
          if (page.imageBase64 != null && page.imageBase64!.isNotEmpty)
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                ),
                color: AppTheme.backgroundColor, // Bej rengi (0xFFF5F5DC)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _decodeBase64Image(page.imageBase64!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Dikey mod için sayfa içeriği (mevcut düzen)
  Widget _buildPortraitPageContent(TalePage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sayfa resmi
          if (page.imageBase64 != null && page.imageBase64!.isNotEmpty)
            Expanded(
              flex: 3,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                ),
                color: AppTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.memory(
                    _decodeBase64Image(page.imageBase64!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
            
          const SizedBox(height: 16),
          
          // Sayfa metni
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
              ),
              color: AppTheme.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    page.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      fontSize: 18.0,
                      color: AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Uint8List _decodeBase64Image(String base64Image) {
    return const Base64Decoder().convert(base64Image);
  }
}
