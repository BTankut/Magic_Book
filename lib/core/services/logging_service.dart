import 'package:logger/logger.dart';

/// Loglama seviyeleri.
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Uygulama genelinde kullanılan loglama servisi.
/// 
/// Bu servis, uygulamanın farklı bölümlerinden gelen log mesajlarını
/// standart bir formatta işler ve kaydeder.
class LoggingService {
  late final Logger _logger;
  
  LoggingService() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        // printTime yerine dateTimeFormat kullanılmalı
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }
  
  /// Trace seviyesinde log kaydı oluşturur.
  /// Level.verbose yerine Level.trace kullanılmalı
  void t(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
  
  /// Verbose seviyesinde log kaydı oluşturur.
  /// @deprecated Level.verbose yerine Level.trace kullanılmalı, v() yerine t() kullanın
  void v(String message, {dynamic error, StackTrace? stackTrace}) {
    t(message, error: error, stackTrace: stackTrace);
  }
  
  /// Debug seviyesinde log kaydı oluşturur.
  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Info seviyesinde log kaydı oluşturur.
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// Warning seviyesinde log kaydı oluşturur.
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// Error seviyesinde log kaydı oluşturur.
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// Fatal seviyesinde log kaydı oluşturur.
  void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
  
  /// Belirtilen seviyede log kaydı oluşturur.
  void log(LogLevel level, String message, {dynamic error, StackTrace? stackTrace}) {
    switch (level) {
      case LogLevel.verbose:
        v(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.debug:
        d(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        i(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        w(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        e(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.fatal:
        wtf(message, error: error, stackTrace: stackTrace);
        break;
    }
  }
}
