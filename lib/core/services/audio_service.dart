import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/main.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/// Ses servisi durumları.
enum AudioState {
  playing,
  stopped,
  paused,
  error,
}

/// Ses servisi.
/// 
/// Bu servis, metinden sese dönüştürme (TTS) işlemlerini yönetir.
class AudioService {
  late FlutterTts _flutterTts;
  AudioState _state = AudioState.stopped;
  final LoggingService _logger;
  
  /// Varsayılan constructor.
  AudioService() : _logger = getIt<LoggingService>();
  
  /// Test için constructor.
  AudioService.withDependencies(this._logger);
  
  /// Test için FlutterTts nesnesini ayarlar.
  @visibleForTesting
  void setTtsForTesting(FlutterTts tts) {
    _flutterTts = tts;
  }
  
  /// Ses servisinin mevcut durumu.
  AudioState get state => _state;
  
  /// Sesli anlatım tamamlandığında çağrılacak fonksiyon.
  Function? onComplete;
  
  /// Ses servisini başlatır.
  Future<void> init() async {
    try {
      _flutterTts = FlutterTts();
      
      // TTS ayarları
      await _flutterTts.setLanguage('tr-TR');
      await _flutterTts.setSpeechRate(0.5); // Daha yavaş konuşma hızı (çocuklar için)
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // TTS tamamlanma olayını dinle
      _flutterTts.setCompletionHandler(() {
        _state = AudioState.stopped;
        _logger.d('TTS tamamlandı');
        
        // onComplete callback'i çağır
        if (onComplete != null) {
          onComplete!();
        }
      });
      
      // TTS hata olayını dinle
      _flutterTts.setErrorHandler((error) {
        _state = AudioState.error;
        _logger.e('TTS hatası: $error');
      });
      
      _logger.i('AudioService başarıyla başlatıldı');
    } catch (e, stackTrace) {
      _state = AudioState.error;
      _logger.e('AudioService başlatılırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Metni sesli olarak okur.
  Future<void> speak(String text) async {
    try {
      if (_state == AudioState.playing) {
        await stop();
      }
      
      _state = AudioState.playing;
      await _flutterTts.speak(text);
      _logger.d('TTS konuşmaya başladı');
    } catch (e, stackTrace) {
      _state = AudioState.error;
      _logger.e('TTS konuşurken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Sesli okumayı duraklatır.
  Future<void> pause() async {
    try {
      if (_state == AudioState.playing) {
        _state = AudioState.paused;
        await _flutterTts.pause();
        _logger.d('TTS duraklatıldı');
      }
    } catch (e, stackTrace) {
      _logger.e('TTS duraklatılırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Duraklatılmış sesli okumayı devam ettirir.
  Future<void> resume() async {
    try {
      if (_state == AudioState.paused) {
        _state = AudioState.playing;
        // Flutter TTS'de doğrudan devam ettirme işlevi yok, 
        // bu nedenle kaldığı yerden devam etmek için özel bir çözüm gerekebilir
        _logger.d('TTS devam ediyor');
      }
    } catch (e, stackTrace) {
      _logger.e('TTS devam ederken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Sesli okumayı durdurur.
  Future<void> stop() async {
    try {
      _state = AudioState.stopped;
      await _flutterTts.stop();
      _logger.d('TTS durduruldu');
    } catch (e, stackTrace) {
      _logger.e('TTS durdurulurken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Metni ses dosyasına dönüştürür ve kaydeder.
  /// 
  /// Dönen değer, kaydedilen ses dosyasının yoludur.
  Future<String?> saveToFile(String text, String fileName) async {
    try {
      // Dosya yolunu oluştur
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/audio/$fileName.wav';
      
      // Dizin yoksa oluştur
      final audioDir = Directory('${directory.path}/audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      // Metni ses dosyasına dönüştür
      await _flutterTts.synthesizeToFile(text, filePath);
      _logger.i('Ses dosyası kaydedildi: $filePath');
      
      return filePath;
    } catch (e, stackTrace) {
      _logger.e('Ses dosyası kaydedilirken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Mevcut dilleri döndürür.
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e, stackTrace) {
      _logger.e('Diller alınırken hata oluştu', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// Konuşma hızını ayarlar.
  /// 
  /// Değer aralığı: 0.0 - 1.0
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e, stackTrace) {
      _logger.e('Konuşma hızı ayarlanırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Ses yüksekliğini ayarlar.
  /// 
  /// Değer aralığı: 0.0 - 1.0
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e, stackTrace) {
      _logger.e('Ses yüksekliği ayarlanırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Ses perdesini ayarlar.
  /// 
  /// Değer aralığı: 0.0 - 2.0
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e, stackTrace) {
      _logger.e('Ses perdesi ayarlanırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Dili ayarlar.
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e, stackTrace) {
      _logger.e('Dil ayarlanırken hata oluştu', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Kaynakları serbest bırakır.
  /// 
  /// Bu metot, servis kullanımı bittiğinde çağrılmalıdır.
  Future<void> dispose() async {
    try {
      // Çalışıyorsa durdur
      if (_state == AudioState.playing || _state == AudioState.paused) {
        await stop();
      }
      
      // FlutterTts kaynağını temizle
      _logger.d('AudioService kaynakları serbest bırakıldı');
    } catch (e, stackTrace) {
      _logger.e('AudioService kaynakları serbest bırakılırken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
}
