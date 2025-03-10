import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/home/screens/home_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';
import 'package:magic_book/shared/widgets/network_status_banner.dart';

/// Masal okuma ekranı.
/// 
/// Bu ekran, oluşturulan masalın okunmasını sağlar ve kitap benzeri bir arayüz sunar.
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
  PageController _pageController = PageController();
  NetworkStatus _networkStatus = NetworkStatus.online;
  
  @override
  void initState() {
    super.initState();
    _loadTale();
    _checkNetworkStatus();
    
    // Ağ durumu değişikliklerini dinle
    _networkService.networkStatusStream.listen((status) {
      setState(() {
        _networkStatus = status;
      });
    });
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newFavoriteStatus 
              ? 'Masal favorilere eklendi.' 
              : 'Masal favorilerden çıkarıldı.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Favori durumu güncellenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favori durumu güncellenirken bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesli anlatım sırasında bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  /// Sonraki sayfaya geçer.
  void _nextPage() {
    if (_tale == null || _currentPageIndex >= _tale!.pages.length - 1) return;
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  /// Önceki sayfaya geçer.
  void _previousPage() {
    if (_tale == null || _currentPageIndex <= 0) return;
    
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  /// Sayfa değiştiğinde çağrılır.
  void _onPageChanged(int index) {
    // Eğer sesli anlatım devam ediyorsa durdur
    if (_isPlaying) {
      _audioService.stop();
    }
    
    setState(() {
      _currentPageIndex = index;
      _isPlaying = false;
    });
    
    _logger.i('Sayfa değiştirildi: ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Ağ durumu banner'ı
          NetworkStatusBanner(),
          
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
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: _tale!.pages.length,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                return _buildPage(index);
                              },
                            )
                          : const Center(child: Text('Masal bulunamadı')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _tale != null ? _buildControlBar() : null,
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
    
    return PageView.builder(
      controller: _pageController,
      itemCount: _tale!.pages.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return _buildPage(index);
      },
    );
  }
  
  /// Sayfayı oluşturur.
  Widget _buildPage(int index) {
    final page = _tale!.pages[index];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Sol sayfa (metin)
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
              ),
              color: AppTheme.cardColor,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
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
              color: AppTheme.cardColor,
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
                          _logger.e('Görsel yüklenirken hata oluştu', error: snapshot.error);
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: AppTheme.errorColor,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  _logger.e('Görsel yüklenirken hata oluştu', error: error, stackTrace: stackTrace);
                                  return Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: AppTheme.errorColor,
                                    ),
                                  );
                                },
                              ),
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
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Önceki sayfa butonu
          ElevatedButton(
            onPressed: _currentPageIndex > 0 ? _previousPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPageIndex > 0 
                  ? AppTheme.secondaryColor 
                  : Colors.grey.shade600,
              foregroundColor: AppTheme.textLightColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios, size: 16),
                const SizedBox(width: 4),
                const Text('Önceki'),
              ],
            ),
          ),
          
          // Sayfa bilgisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPageIndex + 1} / ${_tale?.pages.length ?? 0}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textLightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Sonraki sayfa butonu
          ElevatedButton(
            onPressed: _tale != null && _currentPageIndex < _tale!.pages.length - 1 
                ? _nextPage 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _tale != null && _currentPageIndex < _tale!.pages.length - 1 
                  ? AppTheme.secondaryColor 
                  : Colors.grey.shade600,
              foregroundColor: AppTheme.textLightColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sonraki'),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          
          // Sesli anlatım butonu
          ElevatedButton(
            onPressed: _toggleAudio,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPlaying 
                  ? Colors.redAccent.shade200 
                  : AppTheme.secondaryColor,
              foregroundColor: AppTheme.textLightColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: Icon(
              _isPlaying ? Icons.stop : Icons.volume_up,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
