import 'package:flutter/material.dart';
import 'package:magic_book/core/services/network_service.dart';
import 'package:magic_book/main.dart';
import 'package:magic_book/shared/theme/app_theme.dart';

/// Ağ bağlantı durumunu gösteren banner.
/// 
/// Bu widget, ağ bağlantı durumunu kullanıcıya bildirir.
/// Çevrimdışı durumda kırmızı bir banner gösterilir.
/// Çevrimiçi durumda yeşil bir banner gösterilir.
class NetworkStatusBanner extends StatefulWidget {
  /// Banner'ın yüksekliği.
  final double height;
  
  /// Banner'ın gösterilme süresi (milisaniye).
  final int displayDuration;
  
  /// Banner'ın kaybolma süresi (milisaniye).
  final int fadeDuration;
  
  /// Banner'ın gösterilip gösterilmeyeceği.
  final bool showBanner;
  
  const NetworkStatusBanner({
    Key? key,
    this.height = 30.0,
    this.displayDuration = 3000,
    this.fadeDuration = 500,
    this.showBanner = true,
  }) : super(key: key);
  
  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> with SingleTickerProviderStateMixin {
  final NetworkService _networkService = getIt<NetworkService>();
  NetworkStatus _networkStatus = NetworkStatus.online;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fadeDuration),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _checkNetworkStatus();
    _networkService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _networkStatus = status;
          _showBanner();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkNetworkStatus() async {
    final status = await _networkService.getCurrentNetworkStatus();
    if (mounted) {
      setState(() {
        _networkStatus = status;
        if (_networkStatus == NetworkStatus.offline && widget.showBanner) {
          _showBanner();
        }
      });
    }
  }
  
  void _showBanner() {
    setState(() {
      _isVisible = true;
    });
    
    _animationController.forward();
    
    Future.delayed(Duration(milliseconds: widget.displayDuration), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
          }
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible || !widget.showBanner) {
      return const SizedBox.shrink();
    }
    
    final bool isOffline = _networkStatus == NetworkStatus.offline;
    final Color backgroundColor = isOffline ? AppTheme.errorColor : AppTheme.successColor;
    final String message = isOffline ? 'Çevrimdışı modu - Sadece favori masallar görüntülenebilir' : 'Çevrimiçi moda geçildi';
    final IconData icon = isOffline ? Icons.wifi_off : Icons.wifi;
    
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: backgroundColor,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
