import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/shared/models/tale.dart';

// Mock sınıflarını oluştur
@GenerateNiceMocks([
  MockSpec<LoggingService>(),
  MockSpec<StorageService>(),
  MockSpec<NetworkService>(),
])
import 'download_manager_test.mocks.dart';

void main() {
  late DownloadManager downloadManager;
  late MockLoggingService mockLoggingService;
  late MockStorageService mockStorageService;
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockLoggingService = MockLoggingService();
    mockStorageService = MockStorageService();
    mockNetworkService = MockNetworkService();
    
    // NetworkService mock ayarları
    when(mockNetworkService.isOnline).thenReturn(true);
    when(mockNetworkService.networkStatusStream)
        .thenAnswer((_) => Stream.value(NetworkStatus.online));
    
    // GetIt yerine manuel olarak bağımlılıkları enjekte ediyoruz
    downloadManager = DownloadManager.withDependencies(
      mockLoggingService,
      mockStorageService,
      mockNetworkService,
    );
  });

  group('DownloadManager Tests', () {
    test('İndirme durumunu doğru şekilde takip etmeli', () {
      // Arrange
      final String taleId = 'test_tale_id';
      
      // Act
      downloadManager.queueDownload(taleId);
      
      // Assert
      expect(downloadManager.getDownloadStatus(taleId), equals(DownloadStatus.pending));
    });

    test('İndirme kuyruğuna ekleme ve kuyruktan çıkarma işlemleri doğru çalışmalı', () {
      // Arrange
      final String taleId = 'test_tale_id';
      
      // Act
      downloadManager.queueDownload(taleId);
      
      // Assert
      expect(downloadManager.isInQueue(taleId), isTrue);
      
      // Act
      downloadManager.removeFromQueue(taleId);
      
      // Assert
      expect(downloadManager.isInQueue(taleId), isFalse);
    });

    test('Çevrimdışı durumda indirme işlemi başlatılmamalı', () {
      // Arrange
      final String taleId = 'test_tale_id';
      when(mockNetworkService.isOnline).thenReturn(false);
      
      // NetworkService'in değişimini bildiriyoruz
      when(mockNetworkService.networkStatusStream)
          .thenAnswer((_) => Stream.value(NetworkStatus.offline));
      
      // Act
      downloadManager.queueDownload(taleId);
      downloadManager.startDownload();
      
      // Assert
      expect(downloadManager.getDownloadStatus(taleId), equals(DownloadStatus.pending));
      verify(mockLoggingService.warning(any)).called(1);
    });

    test('İndirme tamamlandığında durum güncellenmelidir', () async {
      // Arrange
      final String taleId = 'test_tale_id';
      final Tale mockTale = Tale(
        id: taleId,
        title: 'Test Tale',
        theme: TaleTheme.adventure,
        setting: TaleSetting.forest,
        wordCount: 100,
        pages: [],
        createdAt: DateTime.now(),
        isFavorite: true,
      );
      
      when(mockStorageService.getTale(taleId)).thenAnswer((_) async => mockTale);
      
      // Act
      downloadManager.queueDownload(taleId);
      await downloadManager.downloadTale(taleId);
      
      // Assert
      expect(downloadManager.getDownloadStatus(taleId), equals(DownloadStatus.completed));
    });

    test('İndirme başarısız olduğunda durum güncellenmelidir', () async {
      // Arrange
      final String taleId = 'test_tale_id';
      
      when(mockStorageService.getTale(taleId)).thenThrow(Exception('Test error'));
      
      // Act
      downloadManager.queueDownload(taleId);
      await downloadManager.downloadTale(taleId);
      
      // Assert
      expect(downloadManager.getDownloadStatus(taleId), equals(DownloadStatus.failed));
      verify(mockLoggingService.error(any, any)).called(1);
    });
  });
}
