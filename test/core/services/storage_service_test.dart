import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/user_profile.dart';

// Mock sınıflarını oluştur
@GenerateNiceMocks([
  MockSpec<LoggingService>(),
  MockSpec<Box<UserProfile>>(as: #MockUserProfileBox),
  MockSpec<Box<Tale>>(as: #MockTaleBox),
  MockSpec<Box<dynamic>>(as: #MockSettingsBox),
])
import 'storage_service_test.mocks.dart';

void main() {
  late StorageService storageService;
  late MockLoggingService mockLoggingService;
  late MockUserProfileBox mockUserProfilesBox;
  late MockTaleBox mockFavoriteTalesBox;
  late MockSettingsBox mockAppSettingsBox;

  setUp(() {
    mockLoggingService = MockLoggingService();
    mockUserProfilesBox = MockUserProfileBox();
    mockFavoriteTalesBox = MockTaleBox();
    mockAppSettingsBox = MockSettingsBox();
    
    storageService = StorageService.withDependencies(
      mockLoggingService,
      mockUserProfilesBox,
      mockFavoriteTalesBox,
      mockAppSettingsBox,
    );
  });

  group('UserProfile Tests', () {
    test('getAllUserProfiles tüm profilleri döndürmeli', () {
      // Arrange
      final profiles = [
        UserProfile(
          id: '1',
          name: 'Test User 1',
          age: 8,
          gender: Gender.male,
          hairColor: HairColor.brown,
          hairType: HairType.curly,
          skinTone: SkinTone.medium,
        ),
        UserProfile(
          id: '2',
          name: 'Test User 2',
          age: 6,
          gender: Gender.female,
          hairColor: HairColor.blonde,
          hairType: HairType.straight,
          skinTone: SkinTone.light,
        ),
      ];
      
      when(mockUserProfilesBox.values).thenReturn(profiles);
      
      // Act
      final result = storageService.getAllUserProfiles();
      
      // Assert
      expect(result, equals(profiles));
      expect(result.length, equals(2));
    });

    test('getUserProfile var olan profili döndürmeli', () {
      // Arrange
      final profile = UserProfile(
        id: '1',
        name: 'Test User',
        age: 8,
        gender: Gender.male,
        hairColor: HairColor.brown,
        hairType: HairType.curly,
        skinTone: SkinTone.medium,
      );
      
      when(mockUserProfilesBox.get('1')).thenReturn(profile);
      
      // Act
      final result = storageService.getUserProfile('1');
      
      // Assert
      expect(result, equals(profile));
    });

    test('saveUserProfile yeni profil kaydetmeli', () {
      // Arrange
      final profile = UserProfile(
        id: '1',
        name: 'Test User',
        age: 8,
        gender: Gender.male,
        hairColor: HairColor.brown,
        hairType: HairType.curly,
        skinTone: SkinTone.medium,
      );
      
      when(mockUserProfilesBox.put('1', profile)).thenAnswer((_) async => {});
      
      // Act
      storageService.saveUserProfile(profile);
      
      // Assert
      verify(mockUserProfilesBox.put('1', profile)).called(1);
    });

    test('deleteUserProfile profili silmeli', () {
      // Arrange
      when(mockUserProfilesBox.delete('1')).thenAnswer((_) async => {});
      
      // Act
      storageService.deleteUserProfile('1');
      
      // Assert
      verify(mockUserProfilesBox.delete('1')).called(1);
    });
  });

  group('Tale Tests', () {
    test('getFavoriteTales tüm favori masalları döndürmeli', () {
      // Arrange
      final tales = [
        Tale(
          id: '1',
          title: 'Test Tale 1',
          theme: TaleTheme.adventure,
          setting: TaleSetting.forest,
          wordCount: 100,
          pages: [],
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
        Tale(
          id: '2',
          title: 'Test Tale 2',
          theme: TaleTheme.fantasy,
          setting: TaleSetting.castle,
          wordCount: 200,
          pages: [],
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
      ];
      
      when(mockFavoriteTalesBox.values).thenReturn(tales);
      
      // Act
      final result = storageService.getFavoriteTales();
      
      // Assert
      expect(result, equals(tales));
      expect(result.length, equals(2));
    });

    test('saveTale masalı kaydetmeli', () {
      // Arrange
      final tale = Tale(
        id: '1',
        title: 'Test Tale',
        theme: TaleTheme.adventure,
        setting: TaleSetting.forest,
        wordCount: 100,
        pages: [],
        createdAt: DateTime.now(),
        isFavorite: true,
      );
      
      when(mockFavoriteTalesBox.put('1', tale)).thenAnswer((_) async => {});
      
      // Act
      storageService.saveTale(tale);
      
      // Assert
      verify(mockFavoriteTalesBox.put('1', tale)).called(1);
    });

    test('deleteTale masalı silmeli', () {
      // Arrange
      when(mockFavoriteTalesBox.delete('1')).thenAnswer((_) async => {});
      
      // Act
      storageService.deleteTale('1');
      
      // Assert
      verify(mockFavoriteTalesBox.delete('1')).called(1);
    });

    test('updateTale masalı güncellemeli', () {
      // Arrange
      final tale = Tale(
        id: '1',
        title: 'Test Tale',
        theme: TaleTheme.adventure,
        setting: TaleSetting.forest,
        wordCount: 100,
        pages: [],
        createdAt: DateTime.now(),
        isFavorite: true,
      );
      
      when(mockFavoriteTalesBox.put('1', tale)).thenAnswer((_) async => {});
      
      // Act
      storageService.updateTale(tale);
      
      // Assert
      verify(mockFavoriteTalesBox.put('1', tale)).called(1);
    });
  });

  group('Settings Tests', () {
    test('saveActiveProfileId aktif profil ID\'sini kaydetmeli', () {
      // Arrange
      when(mockAppSettingsBox.put('activeProfileId', '1')).thenAnswer((_) async => {});
      
      // Act
      storageService.saveActiveProfileId('1');
      
      // Assert
      verify(mockAppSettingsBox.put('activeProfileId', '1')).called(1);
    });

    test('getActiveProfileId aktif profil ID\'sini döndürmeli', () {
      // Arrange
      when(mockAppSettingsBox.get('activeProfileId')).thenReturn('1');
      
      // Act
      final result = storageService.getActiveProfileId();
      
      // Assert
      expect(result, equals('1'));
    });
  });
}
