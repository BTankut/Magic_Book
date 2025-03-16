import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/book/widgets/ipad_book_view.dart';
import 'package:magic_book/features/home/screens/home_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/utils/device_utils.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';
import 'package:magic_book/shared/widgets/network_status_banner.dart';
import 'package:magic_book/shared/widgets/responsive_builder.dart';

/// Masal okuma ekranı.
/// 
/// Bu ekran, oluşturulan masalın okunmasını sağlar ve kitap benzeri bir arayüz sunar.
/// iPad için özel görünüm desteği eklenmiştir.
class TaleViewerScreen extends StatefulWidget {
  /// Okunacak masalın ID'si.
  final String taleId;

  const TaleViewerScreen({
    super.key,
    required this.taleId,
  });

  @override
  State<TaleViewerScreen> createState() => _TaleViewerScreenState();
}

class _TaleViewerScreenState extends State<TaleViewerScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  final AudioService _audioService = getIt<AudioService>();
  final NetworkService _networkService = getIt<NetworkService>();
  final ImageCacheService _imageCacheService = getIt<ImageCacheService>();
  
  Tale? _tale;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFavorite = false;
  bool _isPlaying = false;
  int _currentPageIndex = 0;
  NetworkStatus _networkStatus = NetworkStatus.online;
  
  @override
  void initState() {
    super.initState();
    
    // Başlangıç ayarları
    _isLoading = true;
    _currentPageIndex = 0;
    _isPlaying = false;
    _isFavorite = false;
    _errorMessage = '';
    
    // Ağ bağlantısını kontrol et
    _checkNetworkStatus();
    
    // Masalı yükle
    _loadTale();
    
    // Ağ durumu değişikliklerini dinle
    _networkService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _networkStatus = status;
        });
      }
    });
    
    _logger.i('TaleViewerScreen başlatıldı');
  }
  
  @override
  void dispose() {
    // Sesli anlatımı durdur
    if (_isPlaying) {
      _audioService.stop();
    }
    
    // AudioService'i temizle
    _audioService.dispose();
    
    _logger.i('TaleViewerScreen kapatıldı');
    super.dispose();
  }
  
  /// Ağ bağlantı durumunu kontrol eder.
  Future<void> _checkNetworkStatus() async {
    try {
      final status = await _networkService.getCurrentNetworkStatus();
      setState(() {
        _networkStatus = status;
      });
      _logger.i('Ağ bağlantı durumu: $_networkStatus');
    } catch (e, stackTrace) {
      _logger.e('Ağ bağlantı durumu kontrol edilirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Masalı yükler.
  Future<void> _loadTale() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tale = _storageService.getTale(widget.taleId);
      
      if (tale == null) {
        _logger.w('Masal bulunamadı: ${widget.taleId}');
        setState(() {
          _errorMessage = 'Masal bulunamadı. Lütfen tekrar deneyin.';
        });
      } else {
        _logger.i('Masal yüklendi: ${tale.id}');
        setState(() {
          _tale = tale;
          _isFavorite = tale.isFavorite;
        });
      }
    } catch (e, stackTrace) {
      _logger.e('Masal yüklenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      setState(() {
        _errorMessage = 'Masal yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Masalı favorilere ekler veya favorilerden çıkarır.
  Future<void> _toggleFavorite() async {
    if (_tale == null) return;
    
    try {
      final newFavoriteStatus = !_isFavorite;
      
      // Eğer favorilere ekliyorsak ve favori sayısı limitine ulaşıldıysa
      if (newFavoriteStatus) {
        final favoriteTales = _storageService.getFavoriteTales();
        if (favoriteTales.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('En fazla 5 masal favorilere eklenebilir. Lütfen önce bir masalı favorilerden çıkarın.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
      }
      
      // Favori durumunu güncelle
      final updatedTale = _tale!.copyWithFavorite(newFavoriteStatus);
      await _storageService.updateTale(updatedTale);
      
      setState(() {
        _tale = updatedTale;
        _isFavorite = newFavoriteStatus;
      });
      
      _logger.i('Masal favori durumu güncellendi: ${_tale!.id}, isFavorite: $newFavoriteStatus');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newFavoriteStatus 
                ? 'Masal favorilere eklendi.' 
                : 'Masal favorilerden çıkarıldı.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Favori durumu güncellenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favori durumu güncellenirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Sesli anlatımı başlatır veya durdurur.
  Future<void> _toggleAudio() async {
    if (_tale == null) return;
    
    try {
      if (_isPlaying) {
        await _audioService.stop();
        setState(() {
          _isPlaying = false;
        });
        _logger.i('Sesli anlatım durduruldu');
      } else {
        final currentPage = _tale!.pages[_currentPageIndex];
        
        // Sesli anlatım tamamlandığında çağrılacak callback
        _audioService.onComplete = () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
            _logger.i('Sesli anlatım tamamlandı');
          }
        };
        
        await _audioService.speak(currentPage.content);
        setState(() {
          _isPlaying = true;
        });
        _logger.i('Sesli anlatım başlatıldı: Sayfa ${_currentPageIndex + 1}');
      }
    } catch (e, stackTrace) {
      _logger.e('Sesli anlatım sırasında hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesli anlatım sırasında bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Sonraki sayfaya geçer.
  void _nextPage() {
    final orientation = DeviceUtils.getDeviceOrientation(context);
    final isLandscape = orientation == DeviceOrientation.landscape;
    final isTablet = DeviceUtils.isTablet(context);
    
    // Debug mesajı ekle
    _logger.d('Sonraki sayfa butonu tıklandı: Yatay mod: $isLandscape, Tablet: $isTablet');
    
    if (!mounted) {
      _logger.e('Widget mounted değil');
      return;
    }
    
    if (_currentPageIndex < (_tale?.pages.length ?? 0) - 1) {
      try {
        // PageController kullanmak yerine doğrudan state'i güncelle
        setState(() {
          _currentPageIndex++;
        });
        _logger.d('Sonraki sayfaya geçildi: $_currentPageIndex');
        
        // Sesli anlatım devam ediyorsa durdur
        if (_isPlaying) {
          _audioService.stop();
          setState(() {
            _isPlaying = false;
          });
        }
      } catch (e) {
        _logger.e('Sonraki sayfaya geçiş sırasında hata: $e');
      }
    } else {
      _logger.d('Son sayfadasınız, daha ileri gidemezsiniz');
    }
  }
  
  /// Önceki sayfaya geçer.
  void _previousPage() {
    final orientation = DeviceUtils.getDeviceOrientation(context);
    final isLandscape = orientation == DeviceOrientation.landscape;
    final isTablet = DeviceUtils.isTablet(context);
    
    // Debug mesajı ekle
    _logger.d('Önceki sayfa butonu tıklandı: Yatay mod: $isLandscape, Tablet: $isTablet');
    
    if (!mounted) {
      _logger.e('Widget mounted değil');
      return;
    }
    
    if (_currentPageIndex > 0) {
      try {
        // PageController kullanmak yerine doğrudan state'i güncelle
        setState(() {
          _currentPageIndex--;
        });
        _logger.d('Önceki sayfaya geçildi: $_currentPageIndex');
        
        // Sesli anlatım devam ediyorsa durdur
        if (_isPlaying) {
          _audioService.stop();
          setState(() {
            _isPlaying = false;
          });
        }
      } catch (e) {
        _logger.e('Önceki sayfaya geçiş sırasında hata: $e');
      }
    } else {
      _logger.d('İlk sayfadasınız, daha geri gidemezsiniz');
    }
  }
  
  /// Sayfa değiştiğinde çağrılır.
  void _onPageChanged(int index) {
    if (!mounted) return;
    
    setState(() {
      _currentPageIndex = index;
      _isPlaying = false;
    });
    
    // Sesli anlatım devam ediyorsa durdur
    if (_isPlaying) {
      _audioService.stop();
    }
    
    _logger.i('Sayfa değiştirildi: ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final orientation = DeviceUtils.getDeviceOrientation(context);
    final isLandscape = orientation == DeviceOrientation.landscape;
    final isTablet = DeviceUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Ağ durumu banner'ı
          const NetworkStatusBanner(),
          
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: AppTheme.paperBackgroundDecoration,
              child: _isLoading
                  ? _buildLoadingContent()
                  : _errorMessage.isNotEmpty
                      ? _buildErrorContent()
                      : _tale != null 
                          ? _buildResponsiveBookView()
                          : const Center(child: Text('Masal bulunamadı')),
            ),
          ),
        ],
      ),
      // Alt kontrol çubuğunu sadece dikey modda veya tablet olmayan cihazlarda göster
      bottomNavigationBar: (isLandscape && isTablet) ? null : (_tale != null ? _buildControlBar() : null),
    );
  }
  
  /// Cihaz tipine göre uygun kitap görünümünü oluşturur
  Widget _buildResponsiveBookView() {
    if (_tale == null) {
      return const Center(child: Text('Hikaye yüklenemedi'));
    }
    
    return ResponsiveBuilder(
      // Mobil görünüm (varsayılan)
      mobileBuilder: (context, constraints) {
        // PageView.builder yerine IndexedStack kullanarak geçerli sayfayı göster
        return IndexedStack(
          index: _currentPageIndex,
          children: List.generate(
            _tale!.pages.length,
            (index) => _buildPage(index),
          ),
        );
      },
      
      // Tablet (iPad) görünümü
      tabletBuilder: (context, constraints) {
        final orientation = DeviceUtils.getDeviceOrientation(context);
        
        // Dikey modda normal görünüm, yatay modda iPad özel görünümü kullan
        if (orientation == DeviceOrientation.portrait) {
          // PageView.builder yerine IndexedStack kullanarak geçerli sayfayı göster
          return IndexedStack(
            index: _currentPageIndex,
            children: List.generate(
              _tale!.pages.length,
              (index) => _buildTabletPortraitPage(index),
            ),
          );
        } else {
          // Yatay modda IPadBookView'ı tamamen bağımsız olarak kullan
          _logger.i('IPadBookView yatay modda oluşturuluyor (sayfa: $_currentPageIndex)');
          return IPadBookView(
            tale: _tale!,
            initialPage: _currentPageIndex,
            isPlaying: _isPlaying,
            onAudioToggle: () {
              _toggleAudio();
            },
            onPageChanged: (index) {
              // Burada doğrudan state'i güncelle
              if (mounted) {
                setState(() {
                  _currentPageIndex = index;
                  // Sesli anlatım devam ediyorsa durdur
                  if (_isPlaying) {
                    _audioService.stop();
                    _isPlaying = false;
                  }
                });
                
                _logger.i('Sayfa değiştirildi (IPadBookView): ${index + 1}');
              }
            },
          );
        }
      },
    );
  }
  
  /// Tablet için dikey mod sayfa görünümü
  Widget _buildTabletPortraitPage(int index) {
    final page = _tale!.pages[index];
    
    return Padding(
      padding: const EdgeInsets.all(24.0), // iPad için daha geniş padding
      child: Column(
        children: [
          // Sayfa numarası
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sayfa ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textLightColor,
                fontSize: 18, // iPad için daha büyük font
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Görsel
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
                child: FutureBuilder<Uint8List?>(
                  future: _getImageBytes(page.imageBase64!, '${_tale!.id}_page_$index'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 80, // iPad için daha büyük ikon
                          color: AppTheme.errorColor,
                        ),
                      );
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 80,
                                color: AppTheme.errorColor,
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            
          const SizedBox(height: 24),
          
          // Metin içeriği
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
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Text(
                    page.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      fontSize: 24.0, // iPad için daha büyük font
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w500,
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

  /// Yükleme içeriğini oluşturur.
  Widget _buildLoadingContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.paperBackgroundDecoration,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
  
  /// Hata içeriğini oluşturur.
  Widget _buildErrorContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade200, // Eksik görsel yerine düz bir renk kullanıyoruz
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
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
                  _errorMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AntiqueButton(
                  text: 'Tekrar Dene',
                  icon: Icons.refresh,
                  onPressed: _loadTale,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Kitap içeriğini oluşturur.
  Widget _buildBookContent() {
    if (_tale == null) return const SizedBox.shrink();
    
    return IndexedStack(
      index: _currentPageIndex,
      children: List.generate(
        _tale!.pages.length,
        (index) => _buildPage(index),
      ),
    );
  }
  
  /// Sayfayı oluşturur.
  Widget _buildPage(int index) {
    final page = _tale!.pages[index];
    final orientation = DeviceUtils.getDeviceOrientation(context);
    final isLandscape = orientation == DeviceOrientation.landscape;
    
    // Yatay ekranda Row, dikey ekranda Column kullan
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLandscape 
          ? _buildLandscapePageContent(page, index) // Yatay ekran düzeni
          : _buildPortraitPageContent(page, index), // Dikey ekran düzeni
    );
  }
  
  /// Yatay ekran için sayfa içeriği (metin solda, resim sağda)
  Widget _buildLandscapePageContent(TalePage page, int index) {
    return Row(
      children: [
        // Sol sayfa (metin)
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
            ),
            color: AppTheme.backgroundColor,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sayfa numarası
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sayfa ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sayfa içeriği
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        page.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          fontSize: 18.0,
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Sağ sayfa (görsel)
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
            ),
            color: AppTheme.backgroundColor,
            child: page.imageBase64 != null && page.imageBase64!.isNotEmpty
                ? FutureBuilder<Uint8List?>(
                    future: _getImageBytes(page.imageBase64!, '${_tale!.id}_page_$index'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: AppTheme.errorColor,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
  
  /// Dikey ekran için sayfa içeriği (resim üstte, metin altta)
  Widget _buildPortraitPageContent(TalePage page, int index) {
    final isTablet = DeviceUtils.isTablet(context);
    
    return Column(
      children: [
        // Sayfa numarası
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Sayfa ${index + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textLightColor,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Üst kısım (görsel)
        Expanded(
          flex: 3,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
            ),
            color: AppTheme.backgroundColor,
            child: page.imageBase64 != null && page.imageBase64!.isNotEmpty
                ? FutureBuilder<Uint8List?>(
                    future: _getImageBytes(page.imageBase64!, '${_tale!.id}_page_$index'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain, // contain kullanarak resmin tamamının görünmesini sağla
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: AppTheme.errorColor,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Alt kısım (metin)
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
                    fontSize: isTablet ? 24.0 : 16.0, // Tablet için 24, telefon için 16 
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center, // Dikey modda metin ortalı olsun
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Görsel verilerini önbellekten veya base64'ten alır.
  Future<Uint8List?> _getImageBytes(String base64String, String cacheKey) async {
    try {
      // Önce önbellekte kontrol et
      final cachedImage = await _imageCacheService.getImage(cacheKey);
      if (cachedImage != null) {
        _logger.d('Görsel önbellekten yüklendi: $cacheKey');
        return cachedImage;
      }
      
      // Önbellekte yoksa base64'ten dönüştür
      final imageBytes = base64Decode(base64String);
      
      // Önbelleğe ekle
      await _imageCacheService.cacheImage(cacheKey, imageBytes);
      _logger.d('Görsel önbelleğe eklendi: $cacheKey');
      
      return imageBytes;
    } catch (e, stackTrace) {
      _logger.e('Görsel işlenirken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Üst bilgi çubuğunu oluşturur.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: AppTheme.textLightColor,
      elevation: 4,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Geri',
        color: AppTheme.textLightColor,
      ),
      title: Text(
        _tale?.title ?? 'Masal',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textLightColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: [
        // Favori butonu
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red[300] : AppTheme.textLightColor,
          ),
          tooltip: _isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
        ),
        // Ana sayfaya dönüş butonu
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: Text(
                    'Ana Sayfaya Dön',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Ana sayfaya dönmek istediğinize emin misiniz?',
                    style: TextStyle(color: AppTheme.textColor),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'İptal',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.textLightColor,
                      ),
                      child: const Text('Ana Sayfa'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.home),
          tooltip: 'Ana Sayfaya Dön',
          color: AppTheme.textLightColor,
        ),
      ],
    );
  }
  
  /// Alt kontrol çubuğunu oluşturur.
  Widget _buildControlBar() {
    // Cihaz tipini kontrol et
    final deviceType = DeviceUtils.getDeviceType(context);
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      height: isTablet ? 80 : 60, // iPad için daha yüksek kontrol çubuğu
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Önceki sayfa butonu
          IconButton(
            onPressed: _currentPageIndex > 0 ? _previousPage : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: _currentPageIndex > 0 ? AppTheme.textLightColor : AppTheme.textLightColor.withOpacity(0.3),
              size: isTablet ? 32 : 24, // iPad için daha büyük ikon
            ),
            tooltip: 'Önceki Sayfa',
          ),
          
          // Sesli anlatım butonu
          IconButton(
            onPressed: _toggleAudio,
            icon: Icon(
              _isPlaying ? Icons.stop : Icons.volume_up,
              color: AppTheme.textLightColor,
              size: isTablet ? 32 : 24, // iPad için daha büyük ikon
            ),
            tooltip: _isPlaying ? 'Sesli Anlatımı Durdur' : 'Sesli Anlat',
          ),
          
          // Sayfa numarası
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 12, 
              vertical: isTablet ? 10 : 6
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Text(
              '${_currentPageIndex + 1} / ${_tale?.pages.length ?? 0}',
              style: TextStyle(
                color: AppTheme.textLightColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 14, // iPad için daha büyük font
              ),
            ),
          ),
          
          // Sonraki sayfa butonu
          IconButton(
            onPressed: _tale != null && _currentPageIndex < _tale!.pages.length - 1 ? _nextPage : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _tale != null && _currentPageIndex < _tale!.pages.length - 1
                  ? AppTheme.textLightColor
                  : AppTheme.textLightColor.withOpacity(0.3),
              size: isTablet ? 32 : 24, // iPad için daha büyük ikon
            ),
            tooltip: 'Sonraki Sayfa',
          ),
        ],
      ),
    );
  }
}
