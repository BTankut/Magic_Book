import 'package:flutter/material.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/home/screens/home_screen.dart';
import 'package:magic_book/features/onboarding/screens/create_profile_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Profil seçme ekranı.
/// 
/// Bu ekran, kullanıcının mevcut profillerden birini seçmesini sağlar.
class SelectProfileScreen extends StatefulWidget {
  const SelectProfileScreen({super.key});

  @override
  State<SelectProfileScreen> createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }
  
  /// Kullanıcı profillerini yükler.
  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final profiles = _storageService.getAllUserProfiles();
      setState(() {
        _profiles = profiles;
      });
      _logger.i('${profiles.length} profil yüklendi');
    } catch (e, stackTrace) {
      _logger.e('Profiller yüklenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profiller yüklenirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Seçilen profili aktif profil olarak ayarlar.
  Future<void> _selectProfile(UserProfile profile) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _storageService.setActiveUserProfile(profile.id);
      _logger.i('Aktif profil ayarlandı: ${profile.id}');
      
      if (mounted) {
        // Ana ekrana yönlendir
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Profil seçilirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil seçilirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Profil silme işlemini onaylar.
  Future<void> _confirmDeleteProfile(UserProfile profile) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Sil'),
        content: Text('${profile.name} profilini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      await _deleteProfile(profile);
    }
  }
  
  /// Profili siler.
  Future<void> _deleteProfile(UserProfile profile) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _storageService.deleteUserProfile(profile.id);
      _logger.i('Profil silindi: ${profile.id}');
      
      // Aktif profil silinen profil ise, aktif profili temizle
      final activeProfileId = _storageService.getActiveUserProfile();
      if (activeProfileId == profile.id) {
        await _storageService.setActiveUserProfile('');
      }
      
      await _loadProfiles();
    } catch (e, stackTrace) {
      _logger.e('Profil silinirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil silinirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Seç'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : _profiles.isEmpty
                    ? _buildEmptyState()
                    : _buildProfileList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProfileScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add),
      ),
    );
  }
  
  /// Profil listesini oluşturur.
  Widget _buildProfileList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profilini Seç',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masallarını kişiselleştirmek için bir profil seç',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _selectProfile(profile),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            profile.name.substring(0, 1).toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Profil bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.age} yaş, ${profile.genderText}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Saç: ${profile.hairColorText}, ${profile.hairTypeText}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Ten: ${profile.skinToneText}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        
                        // Silme butonu
                        IconButton(
                          onPressed: () => _confirmDeleteProfile(profile),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          tooltip: 'Profili Sil',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Profil yoksa boş durum mesajını oluşturur.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz Profil Yok',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Masallarını kişiselleştirmek için yeni bir profil oluştur',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AntiqueButton(
            text: 'Yeni Profil Oluştur',
            icon: Icons.person_add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
