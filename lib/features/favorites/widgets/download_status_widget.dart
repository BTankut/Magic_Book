import 'package:flutter/material.dart';
import 'package:magic_book/core/services/download_manager.dart';
import 'package:provider/provider.dart';

/// İndirme durumu widget'ı.
/// 
/// Bu widget, bir masalın indirme durumunu gösterir ve indirme işlemlerini yönetir.
class DownloadStatusWidget extends StatelessWidget {
  /// Masal ID.
  final String taleId;
  
  const DownloadStatusWidget({
    super.key,
    required this.taleId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadManager, child) {
        final downloadStatus = downloadManager.getTaleDownloadStatus(taleId);
        final downloadProgress = downloadManager.getTaleDownloadProgress(taleId);
        
        // İndirme durumuna göre uygun widget'ı göster
        switch (downloadStatus) {
          case DownloadStatus.pending:
            return _buildPendingWidget(context, downloadManager);
          case DownloadStatus.downloading:
            return _buildDownloadingWidget(context, downloadManager, downloadProgress);
          case DownloadStatus.completed:
            return _buildCompletedWidget(context);
          case DownloadStatus.failed:
            return _buildFailedWidget(context, downloadManager);
        }
      },
    );
  }
  
  /// İndirme bekliyor widget'ı.
  Widget _buildPendingWidget(BuildContext context, DownloadManager downloadManager) {
    return InkWell(
      onTap: () => downloadManager.downloadTale(taleId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_download,
              color: Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'İndir',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// İndiriliyor widget'ı.
  Widget _buildDownloadingWidget(BuildContext context, DownloadManager downloadManager, double progress) {
    return InkWell(
      onTap: () => downloadManager.cancelDownload(taleId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.cancel,
              color: Colors.blue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  /// İndirme tamamlandı widget'ı.
  Widget _buildCompletedWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.offline_pin,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'İndirildi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  
  /// İndirme başarısız widget'ı.
  Widget _buildFailedWidget(BuildContext context, DownloadManager downloadManager) {
    return InkWell(
      onTap: () => downloadManager.downloadTale(taleId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Hata',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.refresh,
              color: Colors.red,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
