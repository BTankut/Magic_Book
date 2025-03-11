import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:path_provider/path_provider.dart';

/// Yerel depolama servisi.
/// 
/// Bu servis, uygulama verilerinin Hive veritabanı kullanılarak
/// yerel olarak depolanmasını sağlar.
class StorageService {
  static const String _userProfileBoxName = 'user_profiles';
  static const String _favoriteTalesBoxName = 'favorite_tales';
  static const String _appSettingsBoxName = 'app_settings';
  
  late Box<UserProfile> _userProfilesBox;
  late Box<Tale> _favoriteTalesBox;
  late Box<dynamic> _appSettingsBox;
  
  final LoggingService _logger;
  
  /// Varsayılan constructor.
  StorageService() : _logger = getIt<LoggingService>();
  
  /// Test için constructor.
  StorageService.withDependencies(
    this._logger,
    this._userProfilesBox,
    this._favoriteTalesBox,
    this._appSettingsBox,
  );
  
  /// Depolama servisini başlatır.
  /// 
  /// Hive adaptörlerini kaydeder ve kutuları açar.
  Future<void> init() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      
      // Eski kutuları temizle (veritabanı şeması değiştiğinde gerekli)
      await _cleanBoxes(appDocumentDir.path);
      
      // Kutuları aç
      _userProfilesBox = await Hive.openBox<UserProfile>(_userProfileBoxName);
      _favoriteTalesBox = await Hive.openBox<Tale>(_favoriteTalesBoxName);
      _appSettingsBox = await Hive.openBox(_appSettingsBoxName);
      
      _logger.i('StorageService başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _logger.e('StorageService başlatılırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Eski Hive kutularını temizler.
  /// 
  /// Bu metod, veritabanı şeması değiştiğinde eski kutuları silmek için kullanılır.
  Future<void> _cleanBoxes(String path) async {
    try {
      // Açık kutuları kapat
      await Hive.close();
      
      // Kutu dosyalarını sil
      final boxNames = [_userProfileBoxName, _favoriteTalesBoxName, _appSettingsBoxName];
      for (final boxName in boxNames) {
        final boxFile = File('$path/$boxName.hive');
        final lockFile = File('$path/$boxName.lock');
        
        if (await boxFile.exists()) {
          await boxFile.delete();
          _logger.i('$boxName kutusu silindi');
        }
        
        if (await lockFile.exists()) {
          await lockFile.delete();
          _logger.i('$boxName kilit dosyası silindi');
        }
      }
    } catch (e, stackTrace) {
      _logger.w('Kutular temizlenirken hata oluştu', error: e, stackTrace: stackTrace);
      // Hata fırlatma, kutuları açmaya devam et
    }
  }
  
  /// Tüm kullanıcı profillerini döndürür.
  List<UserProfile> getAllUserProfiles() {
    try {
      return _userProfilesBox.values.toList();
    } catch (e, stackTrace) {
      _logger.e('Kullanıcı profilleri alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Belirtilen ID'ye sahip kullanıcı profilini döndürür.
  UserProfile? getUserProfile(String id) {
    try {
      return _userProfilesBox.get(id);
    } catch (e, stackTrace) {
      _logger.e('Kullanıcı profili alınırken hata oluştu: $id', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Yeni bir kullanıcı profili kaydeder.
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _userProfilesBox.put(profile.id, profile);
      _logger.i('Kullanıcı profili kaydedildi: ${profile.id}');
    } catch (e, stackTrace) {
      _logger.e('Kullanıcı profili kaydedilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Belirtilen ID'ye sahip kullanıcı profilini siler.
  Future<void> deleteUserProfile(String id) async {
    try {
      await _userProfilesBox.delete(id);
      _logger.i('Kullanıcı profili silindi: $id');
    } catch (e, stackTrace) {
      _logger.e('Kullanıcı profili silinirken hata oluştu: $id', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Tüm favori masalları döndürür.
  List<Tale> getAllFavoriteTales() {
    try {
      return _favoriteTalesBox.values.toList();
    } catch (e, stackTrace) {
      _logger.e('Favori masallar alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Favori masalları döndürür.
  /// 
  /// Bu metod, favorilere eklenmiş tüm masalları döndürür.
  List<Tale> getFavoriteTales() {
    try {
      return _favoriteTalesBox.values.where((tale) => tale.isFavorite).toList();
    } catch (e, stackTrace) {
      _logger.e('Favori masallar alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Belirtilen ID'ye sahip masalı döndürür.
  /// 
  /// Bu metod, belirtilen ID'ye sahip masalı döndürür. Masal bulunamazsa null döner.
  Tale? getTale(String id) {
    try {
      return _favoriteTalesBox.get(id);
    } catch (e, stackTrace) {
      _logger.e('Masal alınırken hata oluştu: $id', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Belirtilen ID'ye sahip favori masalı döndürür.
  Tale? getFavoriteTale(String id) {
    try {
      return _favoriteTalesBox.get(id);
    } catch (e, stackTrace) {
      _logger.e('Favori masal alınırken hata oluştu: $id', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Yeni bir favori masal kaydeder.
  /// 
  /// Maksimum 5 favori masal kaydedilebilir.
  Future<bool> saveFavoriteTale(Tale tale) async {
    try {
      // Maksimum 5 favori masal kontrolü
      if (_favoriteTalesBox.length >= 5 && !_favoriteTalesBox.containsKey(tale.id)) {
        _logger.w('Maksimum favori masal sayısına ulaşıldı (5)');
        return false;
      }
      
      await _favoriteTalesBox.put(tale.id, tale);
      _logger.i('Favori masal kaydedildi: ${tale.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Favori masal kaydedilirken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Belirtilen ID'ye sahip favori masalı siler.
  Future<void> deleteFavoriteTale(String id) async {
    try {
      await _favoriteTalesBox.delete(id);
      _logger.i('Favori masal silindi: $id');
    } catch (e, stackTrace) {
      _logger.e('Favori masal silinirken hata oluştu: $id', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Bir masalı günceller.
  /// 
  /// Bu metod, bir masalın bilgilerini (özellikle favori durumunu) günceller.
  Future<void> updateTale(Tale tale) async {
    try {
      if (tale.isFavorite) {
        // Favori ise favori kutusuna kaydet
        await saveFavoriteTale(tale);
        
        // Favori masallar çevrimdışı erişim için otomatik olarak indirilir
        if (!tale.isFullyDownloaded) {
          await markTaleAsDownloaded(tale.id);
        }
      } else {
        // Favori değilse favori kutusundan sil
        await deleteFavoriteTale(tale.id);
      }
      _logger.i('Masal güncellendi: ${tale.id}, Favori: ${tale.isFavorite}');
    } catch (e, stackTrace) {
      _logger.e('Masal güncellenirken hata oluştu: ${tale.id}', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Bir masalı çevrimdışı erişim için indirilmiş olarak işaretler.
  /// 
  /// Bu metod, bir masalın tüm içeriğinin (metin, görseller, ses) indirildiğini
  /// ve çevrimdışı erişim için hazır olduğunu işaretler.
  Future<void> markTaleAsDownloaded(String taleId) async {
    try {
      final tale = getTale(taleId);
      if (tale != null) {
        final updatedTale = tale.copyWithDownloadStatus(
          isFullyDownloaded: true,
          lastDownloadedAt: DateTime.now(),
        );
        await _favoriteTalesBox.put(taleId, updatedTale);
        _logger.i('Masal çevrimdışı erişim için işaretlendi: $taleId');
      } else {
        _logger.w('İndirilecek masal bulunamadı: $taleId');
      }
    } catch (e, stackTrace) {
      _logger.e('Masal indirme durumu güncellenirken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Bir masalın indirme durumunu günceller.
  /// 
  /// Bu metod, bir masalın indirme durumunu günceller.
  Future<void> updateTaleDownloadStatus(String taleId, bool isDownloaded) async {
    try {
      final tale = getTale(taleId);
      if (tale != null) {
        final updatedTale = tale.copyWithDownloadStatus(
          isFullyDownloaded: isDownloaded,
          lastDownloadedAt: isDownloaded ? DateTime.now() : null,
        );
        await _favoriteTalesBox.put(taleId, updatedTale);
        _logger.i('Masal indirme durumu güncellendi: $taleId, İndirildi: $isDownloaded');
      } else {
        _logger.w('Güncellenecek masal bulunamadı: $taleId');
      }
    } catch (e, stackTrace) {
      _logger.e('Masal indirme durumu güncellenirken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Çevrimdışı erişilebilir masalları döndürür.
  /// 
  /// Bu metod, çevrimdışı erişim için tamamen indirilmiş ve favori olarak işaretlenmiş
  /// masalları döndürür.
  List<Tale> getOfflineAvailableTales() {
    try {
      return _favoriteTalesBox.values
          .where((tale) => tale.isFavorite && tale.isFullyDownloaded)
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Çevrimdışı erişilebilir masallar alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Bir masalın çevrimdışı erişilebilir olup olmadığını kontrol eder.
  /// 
  /// Bu metod, belirtilen ID'ye sahip masalın çevrimdışı erişim için
  /// tamamen indirilip indirilmediğini kontrol eder.
  bool isTaleAvailableOffline(String taleId) {
    try {
      final tale = getTale(taleId);
      return tale != null && tale.isAvailableOffline;
    } catch (e, stackTrace) {
      _logger.e('Masal çevrimdışı erişim kontrolü yapılırken hata oluştu: $taleId', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Uygulama ayarını kaydeder.
  Future<void> saveAppSetting(String key, dynamic value) async {
    try {
      await _appSettingsBox.put(key, value);
      _logger.i('Uygulama ayarı kaydedildi: $key');
    } catch (e, stackTrace) {
      _logger.e('Uygulama ayarı kaydedilirken hata oluştu: $key', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Uygulama ayarını döndürür.
  dynamic getAppSetting(String key, {dynamic defaultValue}) {
    try {
      return _appSettingsBox.get(key, defaultValue: defaultValue);
    } catch (e, stackTrace) {
      _logger.e('Uygulama ayarı alınırken hata oluştu: $key', error: e, stackTrace: stackTrace);
      return defaultValue;
    }
  }
  
  /// Aktif kullanıcı profilini kaydeder.
  Future<void> setActiveUserProfile(String userId) async {
    await saveAppSetting('active_user_profile', userId);
  }
  
  /// Aktif kullanıcı profilini döndürür.
  String? getActiveUserProfile() {
    return getAppSetting('active_user_profile');
  }
  
  /// Servisi kapatır.
  Future<void> dispose() async {
    try {
      await Hive.close();
      _logger.i('StorageService kapatıldı');
    } catch (e, stackTrace) {
      _logger.e('StorageService kapatılırken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
}
