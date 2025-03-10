import 'package:flutter/material.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/home/screens/home_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Profil detayları ekranı.
/// 
/// Bu ekran, kullanıcı profilinin detaylarını görüntüler ve düzenlenmesini sağlar.
class ProfileDetailsScreen extends StatefulWidget {
  /// Profil ID'si.
  final String? profileId;
  
  const ProfileDetailsScreen({
    super.key,
    this.profileId,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Gender _selectedGender = Gender.male;
  int _selectedAge = 5;
  HairColor _selectedHairColor = HairColor.brown;
  HairType _selectedHairType = HairType.straight;
  SkinTone _selectedSkinTone = SkinTone.medium;
  
  bool _isEditing = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  /// Profil bilgilerini yükler.
  Future<void> _loadProfile() async {
    try {
      if (widget.profileId != null) {
        final profile = _storageService.getUserProfile(widget.profileId!);
        if (profile != null) {
          _nameController.text = profile.name;
          _selectedGender = profile.gender;
          _selectedAge = profile.age;
          _selectedHairColor = profile.hairColor;
          _selectedHairType = profile.hairType;
          _selectedSkinTone = profile.skinTone;
          _isEditing = true;
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Profil yüklenirken hata oluştu', error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Profil bilgilerini kaydeder.
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        final profile = UserProfile(
          id: widget.profileId,
          name: _nameController.text.trim(),
          age: _selectedAge,
          gender: _selectedGender,
          hairColor: _selectedHairColor,
          hairType: _selectedHairType,
          skinTone: _selectedSkinTone,
        );
        
        await _storageService.saveUserProfile(profile);
        
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e, stackTrace) {
        _logger.e('Profil kaydedilirken hata oluştu', error: e, stackTrace: stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil kaydedilirken bir hata oluştu')),
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
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Profili Düzenle' : 'Yeni Profil'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // İsim
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir isim girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Cinsiyet
                    Text(
                      'Cinsiyet',
                      style: Theme.of(context).textTheme.titleMedium,
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
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Yaş
                    Text(
                      'Yaş: $_selectedAge',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider(
                      value: _selectedAge.toDouble(),
                      min: 0,
                      max: 12,
                      divisions: 12,
                      label: _selectedAge.toString(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAge = value.toInt();
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Saç rengi
                    DropdownButtonFormField<HairColor>(
                      decoration: const InputDecoration(
                        labelText: 'Saç Rengi',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedHairColor,
                      items: const [
                        DropdownMenuItem(value: HairColor.black, child: Text('Siyah')),
                        DropdownMenuItem(value: HairColor.brown, child: Text('Kahverengi')),
                        DropdownMenuItem(value: HairColor.blonde, child: Text('Sarı')),
                        DropdownMenuItem(value: HairColor.red, child: Text('Kızıl')),
                        DropdownMenuItem(value: HairColor.white, child: Text('Beyaz')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHairColor = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Saç tipi
                    DropdownButtonFormField<HairType>(
                      decoration: const InputDecoration(
                        labelText: 'Saç Tipi',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedHairType,
                      items: const [
                        DropdownMenuItem(value: HairType.straight, child: Text('Düz')),
                        DropdownMenuItem(value: HairType.wavy, child: Text('Dalgalı')),
                        DropdownMenuItem(value: HairType.curly, child: Text('Kıvırcık')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHairType = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ten rengi
                    DropdownButtonFormField<SkinTone>(
                      decoration: const InputDecoration(
                        labelText: 'Ten Rengi',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSkinTone,
                      items: const [
                        DropdownMenuItem(value: SkinTone.veryLight, child: Text('Çok Açık')),
                        DropdownMenuItem(value: SkinTone.light, child: Text('Açık')),
                        DropdownMenuItem(value: SkinTone.medium, child: Text('Orta')),
                        DropdownMenuItem(value: SkinTone.tan, child: Text('Bronz')),
                        DropdownMenuItem(value: SkinTone.dark, child: Text('Koyu')),
                        DropdownMenuItem(value: SkinTone.veryDark, child: Text('Çok Koyu')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSkinTone = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Kaydet butonu
                    AntiqueButton(
                      text: 'Kaydet',
                      onPressed: _saveProfile,
                      icon: Icons.save,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // İptal butonu
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('İptal'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
