import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:lru_cache/lru_cache.dart';

/// Görsel önbellekleme servisi.
/// 
/// Bu servis, görsellerin önbelleğe alınmasını ve önbellekten hızlı bir şekilde
/// erişilmesini sağlar. Hem bellek içi önbellekleme hem de disk önbellekleme
/// özelliklerini destekler.
class ImageCacheService {
  final LoggingService _logger;
  
  /// Bellek içi önbellek (LRU - En Az Kullanılan Önce Çıkar).
  /// 
  /// Bu önbellek, sık kullanılan görselleri RAM'de tutar.
  late LruCache<String, Uint8List> _memoryCache;
  
  /// Disk önbellek dizini.
  late final Directory _cacheDir;
  
  /// Önbellek boyutu limiti (MB).
  final int _maxCacheSizeMB;
  
  /// Maksimum bellek içi önbellek öğe sayısı
  final int _maxMemoryCacheItems;
  
  /// Önbellek başlatıldı mı?
  bool _isInitialized = false;
  
  /// Varsayılan constructor.
  /// 
  /// [maxMemoryCacheSize] parametresi, bellek içi önbellekte tutulacak maksimum görsel sayısıdır.
  /// [maxCacheSizeMB] parametresi, disk önbelleğinin maksimum boyutudur (MB).
  ImageCacheService({
    int maxMemoryCacheSize = 50,
    int maxCacheSizeMB = 100,
  }) : 
    _logger = getIt<LoggingService>(),
    _maxMemoryCacheItems = maxMemoryCacheSize,
    _maxCacheSizeMB = maxCacheSizeMB {
    _memoryCache = LruCache<String, Uint8List>(_maxMemoryCacheItems);
  }
  
  /// Test için constructor.
  ImageCacheService.withDependencies(
    this._logger,
    LruCache<String, Uint8List> memoryCache,
    this._maxCacheSizeMB,
    this._maxMemoryCacheItems,
  ) {
    _memoryCache = memoryCache;
  }
  
  /// Önbellekleme servisini başlatır.
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Önbellek dizinini oluştur
      final appCacheDir = await getTemporaryDirectory();
      _cacheDir = Directory('${appCacheDir.path}/image_cache');
      
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }
      
      // Önbellek boyutunu kontrol et ve gerekirse temizle
      await _cleanupCacheIfNeeded();
      
      _isInitialized = true;
      _logger.i('ImageCacheService başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _logger.e('ImageCacheService başlatılırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Görseli önbelleğe ekler.
  /// 
  /// [key] parametresi, görselin benzersiz anahtarıdır.
  /// [imageBytes] parametresi, görselin bayt dizisidir.
  Future<void> cacheImage(String key, Uint8List imageBytes) async {
    if (!_isInitialized) await init();
    
    try {
      final cacheKey = _generateCacheKey(key);
      
      // Bellek içi önbelleğe ekle
      _memoryCache.put(cacheKey, imageBytes);
      
      // Disk önbelleğine ekle
      final file = File('${_cacheDir.path}/$cacheKey');
      await file.writeAsBytes(imageBytes);
      
      _logger.d('Görsel önbelleğe eklendi: $cacheKey (${_formatSize(imageBytes.length)})');
    } catch (e, stackTrace) {
      _logger.e('Görsel önbelleğe eklenirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Görseli önbellekten alır.
  /// 
  /// [key] parametresi, görselin benzersiz anahtarıdır.
  /// 
  /// Eğer görsel önbellekte bulunuyorsa, görselin bayt dizisini döndürür.
  /// Aksi halde null döndürür.
  Future<Uint8List?> getImage(String key) async {
    if (!_isInitialized) await init();
    
    try {
      final cacheKey = _generateCacheKey(key);
      
      // Bellek içi önbellekte kontrol et
      final cachedImage = _memoryCache.get(cacheKey);
      if (cachedImage != null) {
        _logger.d('Görsel bellek içi önbellekten alındı: $cacheKey');
        return cachedImage;
      }
      
      // Disk önbelleğinde kontrol et
      final file = File('${_cacheDir.path}/$cacheKey');
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        
        // Bellek içi önbelleğe de ekle
        _memoryCache.put(cacheKey, imageBytes);
        
        _logger.d('Görsel disk önbelleğinden alındı: $cacheKey');
        return imageBytes;
      }
      
      return null;
    } catch (e, stackTrace) {
      _logger.e('Görsel önbellekten alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Görselin önbellekte olup olmadığını kontrol eder.
  /// 
  /// [key] parametresi, görselin benzersiz anahtarıdır.
  Future<bool> hasImage(String key) async {
    if (!_isInitialized) await init();
    
    try {
      final cacheKey = _generateCacheKey(key);
      
      // Bellek içi önbellekte kontrol et
      if (_memoryCache.get(cacheKey) != null) {
        return true;
      }
      
      // Disk önbelleğinde kontrol et
      final file = File('${_cacheDir.path}/$cacheKey');
      return await file.exists();
    } catch (e, stackTrace) {
      _logger.e('Görsel önbellekte kontrol edilirken hata oluştu', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Belirtilen görseli önbellekten siler.
  /// 
  /// [key] parametresi, görselin benzersiz anahtarıdır.
  Future<void> removeImage(String key) async {
    if (!_isInitialized) await init();
    
    try {
      final cacheKey = _generateCacheKey(key);
      
      // Bellek içi önbellekten sil
      _memoryCache.remove(cacheKey);
      
      // Disk önbelleğinden sil
      final file = File('${_cacheDir.path}/$cacheKey');
      if (await file.exists()) {
        await file.delete();
        _logger.d('Görsel önbellekten silindi: $cacheKey');
      }
    } catch (e, stackTrace) {
      _logger.e('Görsel önbellekten silinirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Önbelleği tamamen temizler.
  /// 
  /// Bu metod, hem bellek içi önbelleği hem de disk önbelleğini temizler.
  Future<void> clearCache() async {
    if (!_isInitialized) await init();
    
    try {
      // Bellek içi önbelleği temizle
      _memoryCache = LruCache<String, Uint8List>(_maxMemoryCacheItems);
      
      // Disk önbelleğini temizle
      final directory = Directory(_cacheDir.path);
      if (await directory.exists()) {
        await for (final entity in directory.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      
      _logger.i('Önbellek tamamen temizlendi');
    } catch (e, stackTrace) {
      _logger.e('Önbellek temizlenirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Önbellek boyutunu kontrol eder ve gerekirse eski dosyaları temizler.
  Future<void> _cleanupCacheIfNeeded() async {
    try {
      if (!await _cacheDir.exists()) return;
      
      // Önbellek boyutunu hesapla
      final totalSize = await _calculateCacheSize();
      final maxSizeBytes = _maxCacheSizeMB * 1024 * 1024;
      
      // Eğer önbellek boyutu limitin altındaysa, temizleme yapma
      if (totalSize < maxSizeBytes) return;
      
      _logger.i('Önbellek boyutu limiti aşıldı. Temizleme yapılıyor...');
      
      // Dosyaları son değiştirilme tarihine göre sırala (en eski önce)
      final files = await _cacheDir.list().toList();
      files.sort((a, b) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      });
      
      // Önbellek boyutu limitin altına düşene kadar en eski dosyaları sil
      var currentSize = totalSize;
      for (final file in files) {
        if (file is File) {
          final fileSize = await file.length();
          await file.delete();
          currentSize -= fileSize;
          
          _logger.d('Önbellekten eski dosya silindi: ${file.path} (${_formatSize(fileSize)})');
          
          // Eğer önbellek boyutu limitin %80'inin altına düştüyse, temizlemeyi durdur
          if (currentSize < maxSizeBytes * 0.8) break;
        }
      }
      
      _logger.i('Önbellek temizleme tamamlandı. Yeni boyut: ${_formatSize(currentSize)}');
    } catch (e, stackTrace) {
      _logger.e('Önbellek temizlenirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Önbellek boyutunu hesaplar.
  Future<int> _calculateCacheSize() async {
    int totalSize = 0;
    
    try {
      await for (final entity in _cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      _logger.e('Önbellek boyutu hesaplanırken hata oluştu', error: e);
    }
    
    return totalSize;
  }
  
  /// Önbellek anahtarı oluşturur.
  String _generateCacheKey(String key) {
    // MD5 hash kullanarak benzersiz bir anahtar oluştur
    return md5.convert(utf8.encode(key)).toString();
  }
  
  /// Bayt boyutunu okunabilir formata dönüştürür.
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
