import 'package:flutter/material.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/favorites/widgets/favorite_tale_card.dart';
import 'package:magic_book/features/tale_viewer/screens/tale_viewer_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';
import 'package:magic_book/shared/widgets/network_aware_widget.dart';
import 'package:magic_book/shared/widgets/network_status_banner.dart';
import 'package:provider/provider.dart';

/// Favori masallar ekranı.
/// 
/// Bu ekran, kullanıcının favori masallarını listeler ve yönetmesini sağlar.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  final NetworkService _networkService = getIt<NetworkService>();
  
  List<Tale> _favoriteTales = [];
  bool _isLoading = true;
  NetworkStatus _networkStatus = NetworkStatus.online;
  
  @override
  void initState() {
    super.initState();
    _loadFavoriteTales();
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
  
  /// Favori masalları yükler.
  Future<void> _loadFavoriteTales() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final favoriteTales = _storageService.getFavoriteTales();
      
      setState(() {
        _favoriteTales = favoriteTales;
      });
      
      _logger.i('Favori masallar yüklendi: ${favoriteTales.length} masal');
    } catch (e, stackTrace) {
      _logger.e('Favori masallar yüklenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favori masallar yüklenirken bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Masalı favorilerden çıkarır.
  Future<void> _removeFavorite(Tale tale) async {
    try {
      // Favori durumunu güncelle
      final updatedTale = tale.copyWithFavorite(false);
      await _storageService.updateTale(updatedTale);
      
      setState(() {
        _favoriteTales.removeWhere((t) => t.id == tale.id);
      });
      
      _logger.i('Masal favorilerden çıkarıldı: ${tale.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masal favorilerden çıkarıldı.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Masal favorilerden çıkarılırken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masal favorilerden çıkarılırken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Masalı görüntülemek için açar.
  void _openTale(Tale tale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaleViewerScreen(taleId: tale.id),
      ),
    ).then((_) {
      // Ekrandan dönüldüğünde favori durumu değişmiş olabilir, yeniden yükle
      _loadFavoriteTales();
    });
  }
  
  /// Tüm favori masalları indirir.
  void _downloadAllFavoriteTales() {
    try {
      if (_networkStatus == NetworkStatus.offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çevrimdışı moddasınız. Masalları indirmek için internet bağlantısı gereklidir.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
      if (_favoriteTales.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İndirilecek favori masal bulunamadı.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
      // İndirme yöneticisini kullanarak tüm masalları indir
      final downloadManager = Provider.of<DownloadManager>(context, listen: false);
      downloadManager.downloadAllFavoriteTales();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm favori masallar indiriliyor...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      _logger.i('Tüm favori masallar indirme kuyruğuna eklendi');
    } catch (e, stackTrace) {
      _logger.e('Tüm favori masallar indirilirken hata oluştu', error: e, stackTrace: stackTrace);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masallar indirilirken bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Masallarım'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Tüm masalları indir butonu
          if (_networkStatus == NetworkStatus.online && _favoriteTales.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: 'Tüm Masalları İndir',
              onPressed: _downloadAllFavoriteTales,
            ),
        ],
      ),
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
                  : _favoriteTales.isEmpty
                      ? _buildEmptyContent()
                      : _buildFavoritesList(),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Yükleme içeriğini oluşturur.
  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }
  
  /// Boş içerik mesajını oluşturur.
  Widget _buildEmptyContent() {
    return NetworkAwareWidget(
      onlineChild: _buildEmptyContentMessage(
        'Henüz Favori Masalınız Yok',
        'Masalları okurken favori butonuna basarak en sevdiğiniz masalları buraya ekleyebilirsiniz.',
        true
      ),
      offlineChild: _buildEmptyContentMessage(
        'Çevrimdışı Moddasınız',
        'Favori masallarınız çevrimdışı modda görüntülenebilir. İnternet bağlantınızı kontrol edin ve yeni masal oluşturmak için çevrimiçi olun.',
        false
      ),
    );
  }
  
  /// Boş içerik mesajını oluşturur.
  Widget _buildEmptyContentMessage(String title, String message, bool showCreateButton) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (showCreateButton)
              AntiqueButton(
                text: 'Yeni Masal Oluştur',
                icon: Icons.add,
                onPressed: () {
                  Navigator.pop(context); // Ana sayfaya dön
                },
              ),
          ],
        ),
      ),
    );
  }
  
  /// Favoriler listesini oluşturur.
  Widget _buildFavoritesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favori Masallarınız (${_favoriteTales.length}/5)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En sevdiğiniz masalları burada saklayabilirsiniz. En fazla 5 masal favorilere eklenebilir.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (_networkStatus == NetworkStatus.online && _favoriteTales.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _downloadAllFavoriteTales,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Tümünü İndir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _favoriteTales.length,
              itemBuilder: (context, index) {
                final tale = _favoriteTales[index];
                
                return FavoriteTaleCard(
                  tale: tale,
                  onTap: () => _openTale(tale),
                  onRemove: () => _removeFavorite(tale),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
