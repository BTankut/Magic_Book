import 'package:flutter/material.dart';

/// Cihaz tipi enum'u
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Cihaz yönü enum'u
enum DeviceOrientation {
  portrait,
  landscape,
}

/// Cihaz özellikleri yardımcı sınıfı
class DeviceUtils {
  /// Cihaz tipini belirler
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Cihaz yönünü belirler
  static DeviceOrientation getDeviceOrientation(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return width > height 
        ? DeviceOrientation.landscape 
        : DeviceOrientation.portrait;
  }
  
  /// Cihazın iPad olup olmadığını kontrol eder
  static bool isIPad(BuildContext context) {
    // iOS platformunda ve tablet boyutunda ise iPad olarak kabul ediyoruz
    final deviceType = getDeviceType(context);
    final platform = Theme.of(context).platform;
    
    return deviceType == DeviceType.tablet && 
           (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS);
  }
  
  /// Cihazın tablet olup olmadığını kontrol eder
  static bool isTablet(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tablet;
  }
  
  /// Ekran boyutuna göre padding değeri döndürür
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final orientation = getDeviceOrientation(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return orientation == DeviceOrientation.portrait
            ? const EdgeInsets.all(24.0)
            : const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }
  
  /// Ekran boyutuna göre font boyutu çarpanı döndürür
  static double getFontScaleFactor(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.15;
      case DeviceType.desktop:
        return 1.3;
    }
  }
  
  /// Ekran boyutuna göre widget boyutu çarpanı döndürür
  static double getSizeScaleFactor(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.25;
      case DeviceType.desktop:
        return 1.5;
    }
  }
  
  /// Tablet için özel grid sayısı hesaplar
  static int getTabletGridCount(BuildContext context, {int defaultCount = 2}) {
    final orientation = getDeviceOrientation(context);
    final deviceType = getDeviceType(context);
    
    if (deviceType != DeviceType.tablet) return defaultCount;
    
    return orientation == DeviceOrientation.landscape ? defaultCount + 1 : defaultCount;
  }
}
