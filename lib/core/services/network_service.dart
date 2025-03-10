import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';

/// Ağ bağlantı durumu.
enum NetworkStatus {
  online,
  offline,
}

/// Ağ servisi.
/// 
/// Bu servis, ağ bağlantı durumunu izler ve değişiklikleri bildirir.
class NetworkService {
  final Connectivity _connectivity;
  final LoggingService _logger;
  
  StreamController<NetworkStatus> networkStatusController = StreamController<NetworkStatus>.broadcast();
  
  NetworkStatus _lastStatus = NetworkStatus.online;
  
  /// Ağ bağlantı durumu stream'i.
  Stream<NetworkStatus> get networkStatusStream => networkStatusController.stream;
  
  /// Şu anki ağ bağlantı durumu.
  NetworkStatus get currentStatus => _lastStatus;
  
  /// Çevrimiçi durumda mı?
  bool get isOnline => _lastStatus == NetworkStatus.online;
  
  /// Ağ servisini başlatır.
  Future<void> init() async {
    try {
      // İlk bağlantı durumunu kontrol et
      await _checkConnectivity();
      
      // Bağlantı değişikliklerini dinle
      _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        _checkConnectivity();
      });
      
      _logger.i('NetworkService başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _logger.e('NetworkService başlatılırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Ağ bağlantı durumunu kontrol eder.
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.none) {
        _updateNetworkStatus(NetworkStatus.offline);
      } else {
        // Gerçek internet bağlantısını kontrol et
        final hasInternet = await _hasInternetConnection();
        _updateNetworkStatus(hasInternet ? NetworkStatus.online : NetworkStatus.offline);
      }
    } catch (e, stackTrace) {
      _logger.e('Bağlantı durumu kontrol edilirken hata oluştu', error: e, stackTrace: stackTrace);
      _updateNetworkStatus(NetworkStatus.offline);
    }
  }
  
  /// İnternet bağlantısını kontrol eder.
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Ağ bağlantı durumunu günceller.
  void _updateNetworkStatus(NetworkStatus status) {
    if (_lastStatus != status) {
      _lastStatus = status;
      networkStatusController.add(status);
      _logger.i('Ağ bağlantı durumu değişti: $status');
    }
  }
  
  /// Mevcut ağ bağlantı durumunu döndürür.
  Future<NetworkStatus> getCurrentNetworkStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.none) {
        return NetworkStatus.offline;
      } else {
        // Gerçek internet bağlantısını kontrol et
        final hasInternet = await _hasInternetConnection();
        return hasInternet ? NetworkStatus.online : NetworkStatus.offline;
      }
    } catch (e, stackTrace) {
      _logger.e('Mevcut bağlantı durumu alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return NetworkStatus.offline;
    }
  }
  
  /// Ağ servisini kapatır.
  void dispose() {
    networkStatusController.close();
  }
  
  /// Varsayılan constructor.
  NetworkService() : 
    _connectivity = Connectivity(),
    _logger = getIt<LoggingService>() {
  }
    
  /// Test için constructor.
  NetworkService.withDependencies(this._connectivity, this._logger);
}
