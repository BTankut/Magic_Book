import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:magic_book/core/services/image_cache_service.dart';
import 'package:magic_book/core/services/logging_service.dart';
import 'package:magic_book/features/favorites/widgets/download_status_widget.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/models/tale.dart';
import 'package:magic_book/shared/constants/theme.dart';
import 'package:intl/intl.dart';

/// Favori masal kartı.
/// 
/// Bu widget, favori masallar listesinde her bir masalı temsil eden kartı oluşturur.
class FavoriteTaleCard extends StatelessWidget {
  /// Gösterilecek masal.
  final Tale tale;
  
  /// Karta tıklandığında çağrılacak fonksiyon.
  final VoidCallback onTap;
  
  /// Masalı favorilerden çıkarmak için çağrılacak fonksiyon.
  final VoidCallback onRemove;
  
  const FavoriteTaleCard({
    super.key,
    required this.tale,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // İlk sayfanın görselini al (varsa)
    String? firstPageImageBase64;
    if (tale.pages.isNotEmpty && tale.pages.first.imageBase64 != null) {
      firstPageImageBase64 = tale.pages.first.imageBase64;
    }
    
    // Oluşturulma tarihini formatla
    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(tale.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.brown.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Masal kapak görseli
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: firstPageImageBase64 != null
                          ? _buildCachedImage(firstPageImageBase64, '${tale.id}_thumbnail')
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Çevrimdışı erişim göstergesi
                  if (tale.isAvailableOffline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.offline_pin,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Masal bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tale.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tema: ${tale.theme}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Ortam: ${tale.setting}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Oluşturulma: $formattedDate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // İndirme durumu widget'ı
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DownloadStatusWidget(taleId: tale.id),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Masalı oku butonu
                        OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.book, size: 16),
                          label: const Text('Oku'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Favorilerden çıkar butonu
                        OutlinedButton.icon(
                          onPressed: onRemove,
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: const Text('Çıkar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Önbellekten görsel yükler.
  Widget _buildCachedImage(String base64String, String cacheKey) {
    final imageCacheService = getIt<ImageCacheService>();
    final logger = getIt<LoggingService>();
    
    return FutureBuilder<Uint8List?>(
      future: _getImageBytes(base64String, cacheKey, imageCacheService, logger),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          logger.e('Görsel yüklenirken hata oluştu', error: snapshot.error);
          return _buildPlaceholderImage();
        } else {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              logger.e('Görsel yüklenirken hata oluştu', error: error, stackTrace: stackTrace);
              return _buildPlaceholderImage();
            },
          );
        }
      },
    );
  }
  
  /// Görsel verilerini önbellekten veya base64'ten alır.
  Future<Uint8List?> _getImageBytes(
    String base64String, 
    String cacheKey, 
    ImageCacheService imageCacheService,
    LoggingService logger
  ) async {
    try {
      // Önce önbellekte kontrol et
      final cachedImage = await imageCacheService.getImage(cacheKey);
      if (cachedImage != null) {
        logger.d('Görsel önbellekten yüklendi: $cacheKey');
        return cachedImage;
      }
      
      // Önbellekte yoksa base64'ten dönüştür
      final imageBytes = base64Decode(base64String);
      
      // Önbelleğe ekle
      await imageCacheService.cacheImage(cacheKey, imageBytes);
      logger.d('Görsel önbelleğe eklendi: $cacheKey');
      
      return imageBytes;
    } catch (e, stackTrace) {
      logger.e('Görsel işlenirken hata oluştu', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Placeholder görsel oluşturur.
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
