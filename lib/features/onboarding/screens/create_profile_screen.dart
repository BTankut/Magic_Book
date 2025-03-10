import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/home/screens/home_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Kullanıcı profili oluşturma ekranı.
/// 
/// Bu ekran, kullanıcının yeni bir profil oluşturmasını sağlar.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  
  Gender _selectedGender = Gender.male;
  HairColor _selectedHairColor = HairColor.brown;
  HairType _selectedHairType = HairType.straight;
  SkinTone _selectedSkinTone = SkinTone.medium;
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  /// Kullanıcı profilini kaydeder.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      
      // Yeni kullanıcı profili oluştur
      final profile = UserProfile(
        name: name,
        age: age,
        gender: _selectedGender,
        hairColor: _selectedHairColor,
        hairType: _selectedHairType,
        skinTone: _selectedSkinTone,
      );
      
      // Profili kaydet
      await _storageService.saveUserProfile(profile);
      
      // Aktif profil olarak ayarla
      await _storageService.setActiveUserProfile(profile.id);
      
      _logger.i('Yeni kullanıcı profili oluşturuldu: ${profile.id}');
      
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
      _logger.e('Profil kaydedilirken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil kaydedilirken bir hata oluştu. Lütfen tekrar deneyin.'),
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
        title: const Text('Yeni Profil Oluştur'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textLightColor,
        elevation: 2,
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kişisel Bilgiler',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // İsim alanı
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        hintText: 'Karakterin ismini girin',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir isim girin';
                        }
                        if (value.trim().length < 2) {
                          return 'İsim en az 2 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Yaş alanı
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Yaş',
                        hintText: '0-12 arası bir yaş girin',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir yaş girin';
                        }
                        final age = int.tryParse(value.trim());
                        if (age == null) {
                          return 'Geçerli bir yaş girin';
                        }
                        if (age < 0 || age > 12) {
                          return 'Yaş 0-12 arasında olmalıdır';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Cinsiyet seçimi
                    Text(
                      'Cinsiyet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<Gender>(
                            title: const Text('Erkek'),
                            value: Gender.male,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<Gender>(
                            title: const Text('Kız'),
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Saç rengi seçimi
                    Text(
                      'Saç Rengi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<HairColor>(
                      value: _selectedHairColor,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.color_lens),
                      ),
                      items: HairColor.values.map((hairColor) {
                        return DropdownMenuItem<HairColor>(
                          value: hairColor,
                          child: Text(_getHairColorText(hairColor)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHairColor = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Saç tipi seçimi
                    Text(
                      'Saç Tipi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<HairType>(
                      value: _selectedHairType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.waves),
                      ),
                      items: HairType.values.map((hairType) {
                        return DropdownMenuItem<HairType>(
                          value: hairType,
                          child: Text(_getHairTypeText(hairType)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHairType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Ten rengi seçimi
                    Text(
                      'Ten Rengi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<SkinTone>(
                      value: _selectedSkinTone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.face),
                      ),
                      items: SkinTone.values.map((skinTone) {
                        return DropdownMenuItem<SkinTone>(
                          value: skinTone,
                          child: Text(_getSkinToneText(skinTone)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSkinTone = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Kaydet butonu
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            )
                          : AntiqueButton(
                              text: 'Profili Kaydet',
                              icon: Icons.save,
                              onPressed: _saveProfile,
                              width: 200,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Saç rengi enum değerini metne dönüştürür.
  String _getHairColorText(HairColor hairColor) {
    switch (hairColor) {
      case HairColor.black:
        return 'Siyah';
      case HairColor.brown:
        return 'Kahverengi';
      case HairColor.blonde:
        return 'Sarı';
      case HairColor.red:
        return 'Kızıl';
      case HairColor.gray:
        return 'Gri';
      case HairColor.white:
        return 'Beyaz';
      case HairColor.other:
        return 'Diğer';
    }
  }
  
  /// Saç tipi enum değerini metne dönüştürür.
  String _getHairTypeText(HairType hairType) {
    switch (hairType) {
      case HairType.straight:
        return 'Düz';
      case HairType.wavy:
        return 'Dalgalı';
      case HairType.curly:
        return 'Kıvırcık';
      case HairType.coily:
        return 'Sıkı Kıvırcık';
      case HairType.bald:
        return 'Kel';
    }
  }
  
  /// Ten rengi enum değerini metne dönüştürür.
  String _getSkinToneText(SkinTone skinTone) {
    switch (skinTone) {
      case SkinTone.veryLight:
        return 'Çok Açık';
      case SkinTone.light:
        return 'Açık';
      case SkinTone.medium:
        return 'Orta';
      case SkinTone.tan:
        return 'Bronz';
      case SkinTone.dark:
        return 'Koyu';
      case SkinTone.veryDark:
        return 'Çok Koyu';
    }
  }
}
