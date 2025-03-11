import 'package:flutter/foundation.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/main.dart';

/// İndirme durumu.
enum DownloadStatus {
  /// İndirme bekliyor.
  pending,
  
  /// İndiriliyor.
  downloading,
  
  /// İndirme tamamlandı.
  completed,
  
  /// İndirme başarısız oldu.
  failed,
}

/// İndirme yöneticisi.
/// 
/// Bu servis, masalların çevrimdışı erişim için indirilmesini yönetir.
class DownloadManager extends ChangeNotifier {
  final LoggingService _logger;
  final StorageService _storageService;
  final NetworkService _networkService;
  
  /// İndirme durumlarını tutan harita.
  /// 
  /// Anahtar: Masal ID, Değer: İndirme durumu.
  final Map<String, DownloadStatus> _downloadStatuses = {};
  
  /// İndirme işlemlerinin ilerlemesini tutan harita.
  /// 
  /// Anahtar: Masal ID, Değer: İlerleme (0.0 - 1.0).
  final Map<String, double> _downloadProgress = {};
  
  /// İndirme kuyruğu.
  final List<String> _downloadQueue = [];
  
  /// İndirme işlemi devam ediyor mu?
  bool _isDownloading = false;
  
  /// Ağ bağlantısı var mı?
  bool _isOnline = true;
  
  /// Varsayılan constructor.
  /// 
  /// GetIt ile bağımlılıkları enjekte eder.
  DownloadManager() : 
    _logger = getIt<LoggingService>(),
    _storageService = getIt<StorageService>(),
    _networkService = getIt<NetworkService>() {
    _init();
  }
  
  /// Test için constructor.
  /// 
  /// Bağımlılıkları manuel olarak enjekte eder.
  DownloadManager.withDependencies(
    this._logger,
    this._storageService,
    this._networkService,
  ) {
    _init();
  }
  
  /// İndirme yöneticisini başlatır.
  Future<void> _init() async {
    try {
      // Ağ durumu değişikliklerini dinle
      _networkService.networkStatusStream.listen((status) {
        _isOnline = status == NetworkStatus.online;
        
        // Çevrimiçi olduğunda indirme kuyruğunu işle
        if (_isOnline && _downloadQueue.isNotEmpty && !_isDownloading) {
          _processDownloadQueue();
        }
      });
      
      // Mevcut ağ durumunu kontrol et
      _isOnline = await _networkService.getCurrentNetworkStatus() == NetworkStatus.online;
      
      // Favori masalların durumunu kontrol et
      _checkFavoriteTalesStatus();
      
      _logger.i('DownloadManager başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _logger.e('DownloadManager başlatılırken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Favori masalların durumunu kontrol eder.
  Future<void> _checkFavoriteTalesStatus() async {
    try {
      final favoriteTales = _storageService.getFavoriteTales();
      
      for (final tale in favoriteTales) {
        if (tale.isFullyDownloaded) {
          _downloadStatuses[tale.id] = DownloadStatus.completed;
          _downloadProgress[tale.id] = 1.0;
        } else {
          _downloadStatuses[tale.id] = DownloadStatus.pending;
          _downloadProgress[tale.id] = 0.0;
          
          // İndirme kuyruğuna ekle
          if (!_downloadQueue.contains(tale.id)) {
            _downloadQueue.add(tale.id);
          }
        }
      }
      
      // Çevrimiçi ise indirme kuyruğunu işle
      if (_isOnline && _downloadQueue.isNotEmpty && !_isDownloading) {
        _processDownloadQueue();
      }
      
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Favori masalların durumu kontrol edilirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// İndirme kuyruğunu işler.
  Future<void> _processDownloadQueue() async {
    if (_downloadQueue.isEmpty || _isDownloading || !_isOnline) {
      return;
    }
    
    _isDownloading = true;
    
    try {
      while (_downloadQueue.isNotEmpty && _isOnline) {
        final taleId = _downloadQueue.first;
        
        await _downloadTale(taleId);
        
        _downloadQueue.removeAt(0);
      }
    } finally {
      _isDownloading = false;
    }
  }
  
  /// Bir masalı indirir.
  Future<void> _downloadTale(String taleId) async {
    try {
      final tale = _storageService.getTale(taleId);
      
      if (tale == null) {
        _logger.w('İndirilecek masal bulunamadı: $taleId');
        _downloadStatuses[taleId] = DownloadStatus.failed;
        notifyListeners();
        return;
      }
      
      // Zaten indirilmiş mi kontrol et
      if (tale.isFullyDownloaded) {
        _downloadStatuses[taleId] = DownloadStatus.completed;
        _downloadProgress[taleId] = 1.0;
        notifyListeners();
        return;
      }
      
      _downloadStatuses[taleId] = DownloadStatus.downloading;
      _downloadProgress[taleId] = 0.0;
      notifyListeners();
      
      // Masalın tüm içeriği zaten yerel olarak saklandığı için
      // burada sadece indirme simülasyonu yapıyoruz
      // Gerçek bir uygulamada, burada masalın içeriğini (metin, görseller, ses)
      // API'den indirmek gerekebilir
      
      // İndirme simülasyonu
      final totalPages = tale.pages.length;
      for (int i = 0; i < totalPages; i++) {
        // İndirme işlemi iptal edildi mi kontrol et
        if (!_isOnline) {
          _downloadStatuses[taleId] = DownloadStatus.pending;
          notifyListeners();
          return;
        }
        
        // İlerlemeyi güncelle
        _downloadProgress[taleId] = (i + 1) / totalPages;
        notifyListeners();
        
        // Gerçek bir indirme simülasyonu için kısa bir bekleme
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // İndirme tamamlandı
      _downloadStatuses[taleId] = DownloadStatus.completed;
      _downloadProgress[taleId] = 1.0;
      
      // Masalı çevrimdışı erişim için işaretle
      await _storageService.markTaleAsDownloaded(taleId);
      
      _logger.i('Masal başarıyla indirildi: $taleId');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Masal indirilirken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
      _downloadStatuses[taleId] = DownloadStatus.failed;
      notifyListeners();
    }
  }
  
  /// Bir masalın indirme durumunu döndürür.
  DownloadStatus getTaleDownloadStatus(String taleId) {
    return _downloadStatuses[taleId] ?? DownloadStatus.pending;
  }
  
  /// Bir masalın indirme ilerlemesini döndürür.
  double getTaleDownloadProgress(String taleId) {
    return _downloadProgress[taleId] ?? 0.0;
  }
  
  /// Bir masalı indirmeye başlar.
  Future<void> downloadTale(String taleId) async {
    try {
      final tale = _storageService.getTale(taleId);
      
      if (tale == null) {
        _logger.w('İndirilecek masal bulunamadı: $taleId');
        return;
      }
      
      // Zaten indirilmiş mi kontrol et
      if (tale.isFullyDownloaded) {
        _downloadStatuses[taleId] = DownloadStatus.completed;
        _downloadProgress[taleId] = 1.0;
        notifyListeners();
        return;
      }
      
      // İndirme kuyruğuna ekle
      if (!_downloadQueue.contains(taleId)) {
        _downloadQueue.add(taleId);
      }
      
      // Çevrimiçi ise indirme kuyruğunu işle
      if (_isOnline && !_isDownloading) {
        _processDownloadQueue();
      } else {
        _downloadStatuses[taleId] = DownloadStatus.pending;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.e('Masal indirme işlemi başlatılırken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Bir masalın indirme işlemini iptal eder.
  void cancelDownload(String taleId) {
    try {
      // İndirme kuyruğundan çıkar
      _downloadQueue.remove(taleId);
      
      // İndirme durumunu güncelle
      _downloadStatuses[taleId] = DownloadStatus.pending;
      _downloadProgress[taleId] = 0.0;
      
      notifyListeners();
      
      _logger.i('Masal indirme işlemi iptal edildi: $taleId');
    } catch (e, stackTrace) {
      _logger.e('Masal indirme işlemi iptal edilirken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Tüm favori masalları indirir.
  Future<void> downloadAllFavoriteTales() async {
    try {
      final favoriteTales = _storageService.getFavoriteTales();
      
      for (final tale in favoriteTales) {
        if (!tale.isFullyDownloaded && !_downloadQueue.contains(tale.id)) {
          _downloadQueue.add(tale.id);
        }
      }
      
      // Çevrimiçi ise indirme kuyruğunu işle
      if (_isOnline && !_isDownloading) {
        _processDownloadQueue();
      }
    } catch (e, stackTrace) {
      _logger.e('Tüm favori masallar indirilirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// İndirme işlemlerini temizler.
  @override
  void dispose() {
    _downloadQueue.clear();
    _downloadStatuses.clear();
    _downloadProgress.clear();
    super.dispose();
  }
}
