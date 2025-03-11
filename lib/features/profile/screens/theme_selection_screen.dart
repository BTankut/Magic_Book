import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:magic_book/shared/providers/theme_provider.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeTypeProvider);
    final useSystemTheme = ref.watch(useSystemThemeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Seçimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Sistem teması kullanımı
            SwitchListTile(
              title: const Text('Sistem Temasını Kullan'),
              subtitle: const Text('Cihazınızın temasına göre otomatik değişir'),
              value: useSystemTheme,
              onChanged: (value) => toggleUseSystemTheme(ref, value),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Tema Seçenekleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Klasik tema
            _buildThemeCard(
              context,
              title: 'Klasik',
              description: 'Klasik kahverengi tonlarında masal teması',
              themeType: AppTheme.classic,
              isSelected: themeType == AppTheme.classic,
              onTap: () => changeThemeType(ref, AppTheme.classic),
              primaryColor: AppTheme.primaryColor,
              secondaryColor: AppTheme.secondaryColor,
              backgroundColor: AppTheme.backgroundColor,
            ),
            
            const SizedBox(height: 12),
            
            // Fantastik tema
            _buildThemeCard(
              context,
              title: 'Fantastik',
              description: 'Büyülü masallar için mor tonlarında tema',
              themeType: AppTheme.fantasy,
              isSelected: themeType == AppTheme.fantasy,
              onTap: () => changeThemeType(ref, AppTheme.fantasy),
              primaryColor: AppTheme.fantasyPrimaryColor,
              secondaryColor: AppTheme.fantasySecondaryColor,
              backgroundColor: AppTheme.fantasyBackgroundColor,
            ),
            
            const SizedBox(height: 12),
            
            // Deniz teması
            _buildThemeCard(
              context,
              title: 'Deniz',
              description: 'Deniz macerası masalları için mavi tonlarında tema',
              themeType: AppTheme.ocean,
              isSelected: themeType == AppTheme.ocean,
              onTap: () => changeThemeType(ref, AppTheme.ocean),
              primaryColor: AppTheme.oceanPrimaryColor,
              secondaryColor: AppTheme.oceanSecondaryColor,
              backgroundColor: AppTheme.oceanBackgroundColor,
            ),
            
            const SizedBox(height: 12),
            
            // Uzay teması
            _buildThemeCard(
              context,
              title: 'Uzay',
              description: 'Uzay macerası masalları için mor ve siyah tonlarında tema',
              themeType: AppTheme.space,
              isSelected: themeType == AppTheme.space,
              onTap: () => changeThemeType(ref, AppTheme.space),
              primaryColor: AppTheme.spacePrimaryColor,
              secondaryColor: AppTheme.spaceSecondaryColor,
              backgroundColor: AppTheme.spaceBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String description,
    required int themeType,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Renk örnekleri
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: backgroundColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 20,
                      color: primaryColor,
                    ),
                    Container(
                      width: 40,
                      height: 20,
                      color: secondaryColor,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Tema bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Seçim işareti
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}