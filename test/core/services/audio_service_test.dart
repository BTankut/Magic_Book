import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:magic_book/core/services/audio_service.dart';
import 'package:magic_book/core/services/logging_service.dart';

import 'audio_service_test.mocks.dart';

@GenerateMocks([LoggingService, FlutterTts])
void main() {
  late MockLogingService mockLogger;
  late MockFlutterTts mockFlutterTts;
  late AudioService audioService;

  setUp(() {
    mockLogger = MockLogingService();
    mockFlutterTts = MockFlutterTts();
    audioService = AudioService.withDependencies(mockLogger);
    
    // FlutterTts nesnesini mock ile değiştir
    audioService.setTtsForTesting(mockFlutterTts);
  });

  group('AudioService Tests', () {
    test('init - TTS başlatma', () async {
      // Arrange
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setCompletionHandler(any)).thenReturn(null);
      when(mockFlutterTts.setErrorHandler(any)).thenReturn(null);
      
      // Act
      await audioService.init();
      
      // Assert
      verify(mockFlutterTts.setLanguage('tr-TR')).called(1);
      verify(mockFlutterTts.setSpeechRate(0.5)).called(1);
      verify(mockFlutterTts.setVolume(1.0)).called(1);
      verify(mockFlutterTts.setPitch(1.0)).called(1);
      verify(mockFlutterTts.setCompletionHandler(any)).called(1);
      verify(mockFlutterTts.setErrorHandler(any)).called(1);
    });

    test('speak - metni seslendirme', () async {
      // Arrange
      const testText = 'Test metni';
      when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
      
      // Act
      await audioService.speak(testText);
      
      // Assert
      verify(mockFlutterTts.speak(testText)).called(1);
      expect(audioService.state, AudioState.playing);
      verify(mockLogger.d(any)).called(1);
    });

    test('stop - seslendirmeyi durdurma', () async {
      // Arrange
      when(mockFlutterTts.stop()).thenAnswer((_) async => 1);
      
      // Act
      await audioService.stop();
      
      // Assert
      verify(mockFlutterTts.stop()).called(1);
      expect(audioService.state, AudioState.stopped);
      verify(mockLogger.d(any)).called(1);
    });

    test('pause - seslendirmeyi duraklatma', () async {
      // Arrange
      when(mockFlutterTts.pause()).thenAnswer((_) async => 1);
      
      // Act
      await audioService.pause();
      
      // Assert
      verify(mockFlutterTts.pause()).called(1);
      expect(audioService.state, AudioState.paused);
      verify(mockLogger.d(any)).called(1);
    });

    test('onComplete callback çağrılması', () async {
      // Arrange
      bool callbackCalled = false;
      audioService.onComplete = () {
        callbackCalled = true;
      };
      
      // Completion handler'ı manuel olarak çağır
      when(mockFlutterTts.setCompletionHandler(any)).thenAnswer((invocation) {
        final Function completionHandler = invocation.positionalArguments[0];
        completionHandler();
        return null;
      });
      
      // Act
      await audioService.init();
      
      // Assert
      expect(callbackCalled, true);
      expect(audioService.state, AudioState.stopped);
    });

    test('saveAudio - ses dosyası kaydetme', () async {
      // Arrange
      const testText = 'Test metni';
      const testPath = '/test/path/audio.mp3';
      
      when(mockFlutterTts.synthesizeToFile(any, any)).thenAnswer((_) async => 1);
      
      // Act
      final result = await audioService.saveAudio(testText, testPath);
      
      // Assert
      expect(result, true);
      verify(mockFlutterTts.synthesizeToFile(testText, testPath)).called(1);
      verify(mockLogger.i(any)).called(1);
    });

    test('saveAudio - hata durumu', () async {
      // Arrange
      const testText = 'Test metni';
      const testPath = '/test/path/audio.mp3';
      
      when(mockFlutterTts.synthesizeToFile(any, any)).thenThrow(Exception('Test error'));
      
      // Act
      final result = await audioService.saveAudio(testText, testPath);
      
      // Assert
      expect(result, false);
      verify(mockFlutterTts.synthesizeToFile(testText, testPath)).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });
  });
}
