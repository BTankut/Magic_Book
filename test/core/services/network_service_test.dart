import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';

// Mock sınıflarını oluştur
@GenerateNiceMocks([
  MockSpec<Connectivity>(),
  MockSpec<LoggingService>(),
])
import 'network_service_test.mocks.dart';

void main() {
  late NetworkService networkService;
  late MockConnectivity mockConnectivity;
  late MockLoggingService mockLoggingService;
  late StreamController<ConnectivityResult> connectivityStreamController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockLoggingService = MockLoggingService();
    connectivityStreamController = StreamController<ConnectivityResult>.broadcast();
    
    // Connectivity mock ayarları
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => ConnectivityResult.wifi);
    when(mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);
    
    // NetworkService oluştur
    networkService = NetworkService.withDependencies(
      mockConnectivity,
      mockLoggingService,
    );
  });

  tearDown(() {
    connectivityStreamController.close();
  });

  group('NetworkService Tests', () {
    test('init metodu bağlantı durumunu kontrol etmeli', () async {
      // Act
      await networkService.init();
      
      // Assert
      verify(mockConnectivity.checkConnectivity()).called(1);
      expect(networkService.isOnline, isTrue);
    });

    test('Bağlantı değişikliklerini doğru şekilde takip etmeli', () async {
      // Arrange
      await networkService.init();
      
      // Act - Bağlantı kesildi
      connectivityStreamController.add(ConnectivityResult.none);
      await Future.delayed(const Duration(milliseconds: 100)); // Stream işlenmesi için bekle
      
      // Assert
      expect(networkService.isOnline, isFalse);
      expect(networkService.currentStatus, equals(NetworkStatus.offline));
      
      // Act - Bağlantı tekrar kuruldu
      connectivityStreamController.add(ConnectivityResult.wifi);
      await Future.delayed(const Duration(milliseconds: 100)); // Stream işlenmesi için bekle
      
      // Assert
      expect(networkService.isOnline, isTrue);
      expect(networkService.currentStatus, equals(NetworkStatus.online));
    });

    test('checkInternetConnection metodu internet bağlantısını doğru kontrol etmeli', () async {
      // Arrange
      await networkService.init();
      
      // Act & Assert - İnternet bağlantısı var
      expect(await networkService.checkInternetConnection(), isTrue);
      
      // Arrange - İnternet bağlantısı yok
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      
      // Act & Assert - İnternet bağlantısı yok
      expect(await networkService.checkInternetConnection(), isFalse);
    });

    test('dispose metodu stream controller\'ı kapatmalı', () {
      // Act
      networkService.dispose();
      
      // Assert
      expect(networkService.networkStatusController.isClosed, isTrue);
    });
  });
}
