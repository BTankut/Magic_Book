import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/shared/enums/gender.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/models/tale_page.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'storage_service_integration_test.mocks.dart';

@GenerateMocks([
  LoggingService,
  Box,
])
void main() {
  late MockLoggingService mockLoggingService;
  late MockBox<UserProfile> mockUserProfilesBox;
  late MockBox<Tale> mockFavoriteTalesBox;
  late MockBox<dynamic> mockAppSettingsBox;
  late StorageService storageService;

  setUp(() {
    mockLoggingService = MockLoggingService();
    mockUserProfilesBox = MockBox<UserProfile>();
    mockFavoriteTalesBox = MockBox<Tale>();
    mockAppSettingsBox = MockBox<dynamic>();

    storageService = StorageService.withDependencies(
      mockLoggingService,
      mockUserProfilesBox,
      mockFavoriteTalesBox,
      mockAppSettingsBox,
    );
  });

  group('StorageService Entegrasyon Testleri', () {
    test('Kullanıcı profili kaydetme ve alma', () {
      // Test verileri
      final userProfile = UserProfile(
        name: 'Test Kullanıcısı',
        gender: Gender.male,
        age: 8,
        hairColor: 'Siyah',
        hairType: 'Düz',
        skinTone: 'Orta',
      );

      // Mock davranışları
      when(mockUserProfilesBox.put(userProfile.id, userProfile))
          .thenAnswer((_) async {});
      when(mockUserProfilesBox.get(userProfile.id)).thenReturn(userProfile);

      // Profili kaydet
      storageService.saveUserProfile(userProfile);

      // Profili al
      final retrievedProfile = storageService.getUserProfile(userProfile.id);

      // Doğrulama
      verify(mockUserProfilesBox.put(userProfile.id, userProfile)).called(1);
      verify(mockUserProfilesBox.get(userProfile.id)).called(1);
      expect(retrievedProfile, userProfile);
    });

    test('Tüm kullanıcı profillerini alma', () {
      // Test verileri
      final userProfile1 = UserProfile(
        name: 'Kullanıcı 1',
        gender: Gender.male,
        age: 5,
        hairColor: 'Siyah',
        hairType: 'Düz',
        skinTone: 'Açık',
      );

      final userProfile2 = UserProfile(
        name: 'Kullanıcı 2',
        gender: Gender.female,
        age: 7,
        hairColor: 'Sarı',
        hairType: 'Dalgalı',
        skinTone: 'Orta',
      );

      final profiles = [userProfile1, userProfile2];

      // Mock davranışları
      when(mockUserProfilesBox.values).thenReturn(profiles);

      // Tüm profilleri al
      final retrievedProfiles = storageService.getAllUserProfiles();

      // Doğrulama
      verify(mockUserProfilesBox.values).called(1);
      expect(retrievedProfiles.length, 2);
      expect(retrievedProfiles, profiles);
    });

    test('Favori masal kaydetme ve alma', () {
      // Test verileri
      final page = TalePage(
        pageNumber: 1,
        content: 'Test sayfası içeriği',
        imageBase64: 'base64_encoded_image',
        audioPath: 'audio/path.mp3',
      );

      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [page],
        isFavorite: true,
      );

      // Mock davranışları
      when(mockFavoriteTalesBox.length).thenReturn(2); // 5'ten az
      when(mockFavoriteTalesBox.containsKey(tale.id)).thenReturn(false);
      when(mockFavoriteTalesBox.put(tale.id, tale)).thenAnswer((_) async {});
      when(mockFavoriteTalesBox.get(tale.id)).thenReturn(tale);

      // Masalı kaydet
      storageService.saveFavoriteTale(tale);

      // Masalı al
      final retrievedTale = storageService.getFavoriteTale(tale.id);

      // Doğrulama
      verify(mockFavoriteTalesBox.put(tale.id, tale)).called(1);
      verify(mockFavoriteTalesBox.get(tale.id)).called(1);
      expect(retrievedTale, tale);
    });

    test('Maksimum favori masal sayısı kontrolü', () {
      // Test verileri
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
        isFavorite: true,
      );

      // Mock davranışları - 5 favori masal var
      when(mockFavoriteTalesBox.length).thenReturn(5);
      when(mockFavoriteTalesBox.containsKey(tale.id)).thenReturn(false);

      // Masalı kaydet
      final result = storageService.saveFavoriteTale(tale);

      // Doğrulama
      verify(mockFavoriteTalesBox.length).called(1);
      verify(mockFavoriteTalesBox.containsKey(tale.id)).called(1);
      verifyNever(mockFavoriteTalesBox.put(tale.id, tale));
      expect(result, false);
    });

    test('Favori masalı silme', () {
      // Test verileri
      final taleId = 'tale123';

      // Mock davranışları
      when(mockFavoriteTalesBox.delete(taleId)).thenAnswer((_) async {});

      // Masalı sil
      storageService.deleteFavoriteTale(taleId);

      // Doğrulama
      verify(mockFavoriteTalesBox.delete(taleId)).called(1);
    });

    test('Tüm favori masalları alma', () {
      // Test verileri
      final tale1 = Tale(
        title: 'Masal 1',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
        isFavorite: true,
      );

      final tale2 = Tale(
        title: 'Masal 2',
        theme: 'Fantastik',
        setting: 'Kale',
        wordCount: 200,
        userId: 'user123',
        pages: [],
        isFavorite: true,
      );

      final tales = [tale1, tale2];

      // Mock davranışları
      when(mockFavoriteTalesBox.values).thenReturn(tales);

      // Tüm masalları al
      final retrievedTales = storageService.getFavoriteTales();

      // Doğrulama
      verify(mockFavoriteTalesBox.values).called(1);
      expect(retrievedTales.length, 2);
      expect(retrievedTales, tales);
    });

    test('Masal güncelleme - favori yapma', () {
      // Test verileri
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
        isFavorite: true,
      );

      // Mock davranışları
      when(mockFavoriteTalesBox.length).thenReturn(2); // 5'ten az
      when(mockFavoriteTalesBox.containsKey(tale.id)).thenReturn(false);
      when(mockFavoriteTalesBox.put(tale.id, tale)).thenAnswer((_) async {});

      // Masalı güncelle
      storageService.updateTale(tale);

      // Doğrulama
      verify(mockFavoriteTalesBox.length).called(1);
      verify(mockFavoriteTalesBox.containsKey(tale.id)).called(1);
      verify(mockFavoriteTalesBox.put(tale.id, tale)).called(1);
    });

    test('Masal güncelleme - favoriden çıkarma', () {
      // Test verileri
      final tale = Tale(
        title: 'Test Masalı',
        theme: 'Macera',
        setting: 'Orman',
        wordCount: 100,
        userId: 'user123',
        pages: [],
        isFavorite: false,
      );

      // Mock davranışları
      when(mockFavoriteTalesBox.delete(tale.id)).thenAnswer((_) async {});

      // Masalı güncelle
      storageService.updateTale(tale);

      // Doğrulama
      verify(mockFavoriteTalesBox.delete(tale.id)).called(1);
    });
  });
}
