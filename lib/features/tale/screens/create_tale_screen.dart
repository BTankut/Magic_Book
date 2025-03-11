import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/core/services/storage_service.dart';
import 'package:magic_book/features/tale/models/tale_model.dart';
import 'package:magic_book/features/tale_generation/screens/tale_generation_screen.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/models/user_profile.dart';
import 'package:magic_book/shared/widgets/antique_button.dart';

/// Masal oluşturma ekranı.
/// 
/// Bu ekran, kullanıcının masal özelliklerini seçmesini sağlar.
class CreateTaleScreen extends StatefulWidget {
  const CreateTaleScreen({super.key});

  @override
  State<CreateTaleScreen> createState() => _CreateTaleScreenState();
}

class _CreateTaleScreenState extends State<CreateTaleScreen> {
  final LoggingService _logger = getIt<LoggingService>();
  final StorageService _storageService = getIt<StorageService>();
  
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TaleTheme _selectedTheme = TaleTheme.fantasy;
  TaleSetting _selectedSetting = TaleSetting.forest;
  int _selectedWordCount = 300; // Varsayılan kelime sayısı
  
  UserProfile? _activeProfile;
  bool _isLoading = true;
  bool _isCustomWordCount = false;
  final _customWordCountController = TextEditingController(text: '300');
  bool _clearCache = false; // Önbelleği temizle seçeneği
  
  final List<int> _predefinedWordCounts = [100, 200, 300, 400, 500];
  
  @override
  void initState() {
    super.initState();
    _loadActiveProfile();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _customWordCountController.dispose();
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
      }
    }
  }
  
  /// Masal oluşturma işlemini başlatır.
  void _createTale() async {
    if (_activeProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masal oluşturmak için bir profil seçmelisiniz.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Kelime sayısını belirle
    final wordCount = _isCustomWordCount 
        ? int.parse(_customWordCountController.text.trim())
        : _selectedWordCount;
    
    // Masal başlığı
    final title = _titleController.text.trim().isNotEmpty 
        ? _titleController.text.trim()
        : 'Yeni Masal';
    
    // Önbelleği temizle seçeneği
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Önbellekteki görselleri temizle
      if (_clearCache) {
        await _clearImageCache();
      }
      
      // Masal oluşturma ekranına yönlendir
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => TaleGenerationScreen(
            title: title,
            theme: _selectedTheme,
            setting: _selectedSetting,
            wordCount: wordCount,
            userProfile: _activeProfile!,
            forceRefresh: _clearCache, // Önbelleği temizle seçeneği
          ),
        ),
      );
      }
    } catch (e, stackTrace) {
      _logger.e('Masal oluşturulurken hata oluştu', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masal oluşturulurken bir hata oluştu: ${e.toString()}'),
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
  
  /// Görsel önbelleğini temizler.
  Future<void> _clearImageCache() async {
    try {
      final imageCacheService = getIt<ImageCacheService>();
      await imageCacheService.clearCache();
      _logger.i('Görsel önbelleği temizlendi');
    } catch (e, stackTrace) {
      _logger.e('Görsel önbelleği temizlenirken hata oluştu', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masal Oluştur'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textLightColor,
        elevation: 4,
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.paperBackgroundDecoration,
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : _buildForm(),
        ),
      ),
    );
  }
  
  /// Form içeriğini oluşturur.
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masal Özellikleri',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Başlık alanı
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık (İsteğe Bağlı)',
                hintText: 'Masalın başlığını girin',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            // Tema seçimi
            Text(
              'Konu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildThemeSelector(),
            const SizedBox(height: 24),
            
            // Ortam seçimi
            Text(
              'Ortam',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingSelector(),
            const SizedBox(height: 24),
            
            // Kelime sayısı seçimi
            Text(
              'Kelime Sayısı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildWordCountSelector(),
            const SizedBox(height: 24),
            
            // Önbelleği temizle seçeneği
            Row(
              children: [
                Checkbox(
                  value: _clearCache,
                  onChanged: (value) {
                    setState(() {
                      _clearCache = value ?? false;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const Text('Önbelleği Temizle'),
              ],
            ),
            const SizedBox(height: 32),
            
            // Oluştur butonu
            Center(
              child: AntiqueButton(
                text: 'Masal Oluştur',
                icon: Icons.auto_stories,
                onPressed: _createTale,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Tema seçim widgetını oluşturur.
  Widget _buildThemeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaleTheme.values.map((theme) {
        final isSelected = theme == _selectedTheme;
        
        return ChoiceChip(
          label: Text(_getThemeText(theme)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedTheme = theme;
              });
            }
          },
          backgroundColor: AppTheme.cardColor,
          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.textLightColor : AppTheme.textColor.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : AppTheme.primaryLightColor.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
  
  /// Ortam seçim widgetını oluşturur.
  Widget _buildSettingSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaleSetting.values.map((setting) {
        final isSelected = setting == _selectedSetting;
        
        return ChoiceChip(
          label: Text(_getSettingText(setting)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedSetting = setting;
              });
            }
          },
          backgroundColor: AppTheme.cardColor,
          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.textLightColor : AppTheme.textColor.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : AppTheme.primaryLightColor.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
  
  /// Kelime sayısı seçim widgetını oluşturur.
  Widget _buildWordCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Önceden tanımlanmış kelime sayıları
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedWordCounts.map((count) {
            final isSelected = count == _selectedWordCount && !_isCustomWordCount;
            
            return ChoiceChip(
              label: Text('$count'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedWordCount = count;
                    _isCustomWordCount = false;
                    _customWordCountController.text = count.toString();
                  });
                }
              },
              backgroundColor: AppTheme.cardColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.textLightColor : AppTheme.textColor.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.primaryLightColor.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Özel kelime sayısı seçeneği
        Row(
          children: [
            Checkbox(
              value: _isCustomWordCount,
              onChanged: (value) {
                setState(() {
                  _isCustomWordCount = value ?? false;
                  if (_isCustomWordCount) {
                    _customWordCountController.text = _selectedWordCount.toString();
                  }
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Text('Özel Kelime Sayısı'),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _customWordCountController,
                enabled: _isCustomWordCount,
                decoration: const InputDecoration(
                  hintText: 'Kelime sayısı',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (_isCustomWordCount) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kelime sayısı giriniz';
                    }
                    final count = int.tryParse(value.trim());
                    if (count == null) {
                      return 'Geçerli bir sayı giriniz';
                    }
                    if (count < 50) {
                      return 'En az 50 kelime olmalı';
                    }
                    if (count > 1000) {
                      return 'En fazla 1000 kelime olabilir';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Tema adını döndürür.
  String _getThemeText(TaleTheme theme) {
    switch (theme) {
      case TaleTheme.adventure:
        return 'Macera';
      case TaleTheme.fantasy:
        return 'Fantastik';
      case TaleTheme.friendship:
        return 'Arkadaşlık';
      case TaleTheme.nature:
        return 'Doğa';
      case TaleTheme.space:
        return 'Bilim Kurgu';
      case TaleTheme.animals:
        return 'Hayvanlar';
      case TaleTheme.magic:
        return 'Sihir';
      case TaleTheme.heroes:
        return 'Kahramanlar';
    }
  }
  
  /// Ortam adını döndürür.
  String _getSettingText(TaleSetting setting) {
    switch (setting) {
      case TaleSetting.forest:
        return 'Orman';
      case TaleSetting.castle:
        return 'Şato';
      case TaleSetting.space:
        return 'Uzay';
      case TaleSetting.ocean:
        return 'Okyanus';
      case TaleSetting.mountain:
        return 'Dağ';
      case TaleSetting.city:
        return 'Şehir';
      case TaleSetting.village:
        return 'Köy';
      case TaleSetting.island:
        return 'Ada';
      case TaleSetting.desert:
        return 'Çöl';
      case TaleSetting.rainforest:
        return 'Yağmur Ormanı';
    }
  }
}
