import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/favorites/screens/favorites_screen.dart';
import 'package:magic_book/features/profile/screens/profile_details_screen.dart';
import 'package:magic_book/features/profile/screens/theme_selection_screen.dart';
import 'package:magic_book/features/tale/screens/create_tale_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/providers/theme_provider.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';
import 'package:magic_book/shared/widgets/network_status_banner.dart';

/// Ana ekran.
/// 
/// Bu ekran, kullanıcının masal oluşturma, favori masalları görüntüleme
/// ve profil ayarlarına erişim sağlar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  final NetworkService _networkService = getIt<NetworkService>();
  
  UserProfile? _activeProfile;
  bool _isLoading = true;
  NetworkStatus _networkStatus = NetworkStatus.online;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Animasyon kontrolcüsünü başlat
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _loadActiveProfile();
    _checkNetworkStatus();
    
    // Ağ durumu değişikliklerini dinle
    _networkService.networkStatusStream.listen((status) {
      setState(() {
        _networkStatus = status;
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Aktif kullanıcı profilini yükler.
  Future<void> _loadActiveProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final activeProfileId = _storageService.getActiveUserProfile();
      
      if (activeProfileId == null || activeProfileId.isEmpty) {
        _logger.w('Aktif profil bulunamadı');
        setState(() {
          _activeProfile = null;
        });
      } else {
        final profile = _storageService.getUserProfile(activeProfileId);
        
        if (profile == null) {
          _logger.w('Aktif profil ID ile profil bulunamadı: $activeProfileId');
          setState(() {
            _activeProfile = null;
          });
        } else {
          _logger.i('Aktif profil yüklendi: ${profile.id}');
          setState(() {
            _activeProfile = profile;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Aktif profil yüklenirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil bilgileri yüklenirken bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    }
  }

  /// Ağ bağlantı durumunu kontrol eder.
  Future<void> _checkNetworkStatus() async {
    try {
      final status = await _networkService.getCurrentNetworkStatus();
      setState(() {
        _networkStatus = status;
      });
      _logger.i('Ağ bağlantı durumu: $_networkStatus');
    } catch (e, stackTrace) {
      _logger.e('Ağ bağlantı durumu kontrol edilirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Ağ durumu banner'ı
              const NetworkStatusBanner(),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : _buildHomeContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Ana ekran içeriğini oluşturur.
  Widget _buildHomeContent() {
    return Column(
      children: [
        // Üst bilgi çubuğu
        _buildAppBar(),
        
        const SizedBox(height: 32),
        
        // Ana içerik
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Uygulama logosu
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 120,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 32), // Azaltıldı
                    
                    // Karşılama metni
                    Text(
                      _activeProfile != null
                          ? 'Merhaba, ${_activeProfile!.name}!'
                          : 'Merhaba!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Bugün nasıl bir masal dinlemek istersin?',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32), // Azaltıldı
                    
                    // Ana butonlar
                    AntiqueButton(
                      text: 'Yeni Masal Oluştur',
                      icon: Icons.auto_stories,
                      onPressed: () {
                        if (_networkStatus == NetworkStatus.offline) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Çevrimdışı modda yeni masal oluşturamazsınız. Lütfen internet bağlantınızı kontrol edin.'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTaleScreen(),
                          ),
                        );
                      },
                      width: 280,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    AntiqueButton(
                      text: 'Favori Masallarım',
                      icon: Icons.favorite,
                      isPrimary: false,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                      width: 280,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Üst bilgi çubuğunu oluşturur.
  Widget _buildAppBar() {
    final themeType = ref.watch(themeTypeProvider);
    final useSystemTheme = ref.watch(useSystemThemeProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tema butonu (sol taraf)
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSelectionScreen(),
              ),
            );
          },
          icon: const Icon(Icons.color_lens),
          tooltip: 'Tema Değiştir',
        ),
        
        // Başlık
        Column(
          children: [
            Text(
              'Sihirli Kitap',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            if (!useSystemTheme)
              Text(
                AppTheme.themeNames[themeType] ?? "Klasik",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
              ),
          ],
        ),
        
        // Profil butonu (sağ taraf)
        GestureDetector(
          onTap: () {
            if (_activeProfile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDetailsScreen(profileId: _activeProfile!.id),
                ),
              ).then((_) => _loadActiveProfile());
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor,
            child: _activeProfile != null
                ? Text(
                    _activeProfile!.name.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }
}
