import 'package:flutter/material.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/main.dart';

/// Ağ bağlantı durumuna göre farklı içerikler gösteren widget.
/// 
/// Bu widget, ağ bağlantı durumuna göre farklı içerikler gösterir.
/// Çevrimdışı durumda, çevrimdışı içerik gösterilir.
/// Çevrimiçi durumda, çevrimiçi içerik gösterilir.
class NetworkAwareWidget extends StatefulWidget {
  /// Çevrimiçi durumda gösterilecek içerik.
  final Widget onlineChild;
  
  /// Çevrimdışı durumda gösterilecek içerik.
  final Widget offlineChild;
  
  /// Çevrimdışı durumda gösterilecek içerik yerine bir mesaj göstermek için.
  final String? offlineMessage;
  
  /// Çevrimdışı durumda gösterilecek mesajın stili.
  final TextStyle? offlineMessageStyle;
  
  /// Çevrimdışı durumda gösterilecek ikon.
  final IconData? offlineIcon;
  
  /// Çevrimdışı durumda gösterilecek ikonun rengi.
  final Color? offlineIconColor;
  
  /// Çevrimdışı durumda gösterilecek ikonun boyutu.
  final double? offlineIconSize;
  
  /// Çevrimdışı durumda gösterilecek arka plan rengi.
  final Color? offlineBackgroundColor;
  
  const NetworkAwareWidget({
    Key? key,
    required this.onlineChild,
    Widget? offlineChild,
    this.offlineMessage,
    this.offlineMessageStyle,
    this.offlineIcon,
    this.offlineIconColor,
    this.offlineIconSize,
    this.offlineBackgroundColor,
  }) : offlineChild = offlineChild ?? const SizedBox.shrink(),
       super(key: key);
  
  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkService _networkService = getIt<NetworkService>();
  NetworkStatus _networkStatus = NetworkStatus.online;
  
  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    _networkService.networkStatusStream.listen((status) {
      setState(() {
        _networkStatus = status;
      });
    });
  }
  
  Future<void> _checkNetworkStatus() async {
    final status = await _networkService.getCurrentNetworkStatus();
    setState(() {
      _networkStatus = status;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_networkStatus == NetworkStatus.online) {
      return widget.onlineChild;
    } else {
      // Eğer özel bir çevrimdışı içerik belirtilmişse, onu göster
      if (widget.offlineChild != const SizedBox.shrink()) {
        return widget.offlineChild;
      }
      
      // Özel bir çevrimdışı içerik belirtilmemişse, varsayılan çevrimdışı içeriği göster
      return Container(
        color: widget.offlineBackgroundColor ?? Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.offlineIcon != null)
                Icon(
                  widget.offlineIcon ?? Icons.wifi_off,
                  color: widget.offlineIconColor ?? Colors.grey[600],
                  size: widget.offlineIconSize ?? 48.0,
                ),
              const SizedBox(height: 16.0),
              if (widget.offlineMessage != null)
                Text(
                  widget.offlineMessage ?? 'İnternet bağlantısı yok',
                  style: widget.offlineMessageStyle ?? 
                      TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }
  }
}
