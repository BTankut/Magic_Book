import 'package:flutter/material.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/onboarding/screens/create_profile_screen.dart';
import 'package:magic_book/features/profile/screens/select_profile_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Karşılama ekranı.
/// 
/// Bu ekran, uygulamanın ilk açılışında kullanıcıyı karşılar ve
/// kullanıcı profili oluşturma veya mevcut bir profili seçme seçeneklerini sunar.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StorageService _storageService = getIt<StorageService>();
  bool _hasProfiles = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _animationController.forward();
    _checkProfiles();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Mevcut kullanıcı profillerini kontrol eder.
  Future<void> _checkProfiles() async {
    final profiles = _storageService.getAllUserProfiles();
    setState(() {
      _hasProfiles = profiles.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve başlık
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 150,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Magic Book',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kişiselleştirilmiş Masallar Dünyası',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryColor, // Koyu renkli yazı
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Animasyon
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
                      ),
                    ),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "MAGIC\nBOOK",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Butonlar
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                      ),
                    ),
                    child: Column(
                      children: [
                        AntiqueButton(
                          text: 'Yeni Profil Oluştur',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateProfileScreen(),
                              ),
                            );
                          },
                          icon: Icons.person_add,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (_hasProfiles)
                          AntiqueButton(
                            text: 'Profil Seç',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectProfileScreen(),
                                ),
                              );
                            },
                            icon: Icons.people,
                            isPrimary: false,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
