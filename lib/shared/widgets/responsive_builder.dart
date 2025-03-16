import 'package:flutter/material.dart';
import 'package:magic_book/shared/utils/device_utils.dart';

/// Responsive tasarım için builder widget
/// 
/// Bu widget, farklı cihaz tiplerine göre farklı arayüzler sunar.
/// Özellikle iPad ve telefon arasındaki farkları yönetmek için kullanılır.
class ResponsiveBuilder extends StatelessWidget {
  /// Mobil cihazlar için builder
  final Widget Function(BuildContext context, BoxConstraints constraints) mobileBuilder;
  
  /// Tablet cihazlar için builder (iPad dahil)
  final Widget Function(BuildContext context, BoxConstraints constraints)? tabletBuilder;
  
  /// Masaüstü cihazlar için builder
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktopBuilder;
  
  /// Yatay mod için özel builder
  final Widget Function(BuildContext context, BoxConstraints constraints)? landscapeBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.landscapeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = DeviceUtils.getDeviceType(context);
        final orientation = DeviceUtils.getDeviceOrientation(context);
        
        // Yatay mod için özel builder varsa ve cihaz yatay moddaysa
        if (landscapeBuilder != null && orientation == DeviceOrientation.landscape) {
          return landscapeBuilder!(context, constraints);
        }
        
        // Cihaz tipine göre uygun builder'ı seç
        switch (deviceType) {
          case DeviceType.mobile:
            return mobileBuilder(context, constraints);
          
          case DeviceType.tablet:
            // Tablet builder varsa kullan, yoksa mobil builder'ı kullan
            return tabletBuilder != null 
                ? tabletBuilder!(context, constraints)
                : mobileBuilder(context, constraints);
          
          case DeviceType.desktop:
            // Sırasıyla desktop, tablet veya mobil builder'ı kullan
            if (desktopBuilder != null) {
              return desktopBuilder!(context, constraints);
            } else if (tabletBuilder != null) {
              return tabletBuilder!(context, constraints);
            } else {
              return mobileBuilder(context, constraints);
            }
        }
      },
    );
  }
}

/// Responsive padding widget
///
/// Cihaz tipine göre otomatik padding uygular
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = DeviceUtils.getDeviceType(context);
    
    EdgeInsets padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobilePadding ?? const EdgeInsets.all(16.0);
        break;
      case DeviceType.tablet:
        padding = tabletPadding ?? const EdgeInsets.all(24.0);
        break;
      case DeviceType.desktop:
        padding = desktopPadding ?? const EdgeInsets.all(32.0);
        break;
    }
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive container widget
///
/// Cihaz tipine göre otomatik genişlik ayarlar
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = DeviceUtils.getDeviceType(context);
    final screenSize = MediaQuery.of(context).size;
    
    double? width;
    double? height;
    
    switch (deviceType) {
      case DeviceType.mobile:
        width = mobileWidth;
        height = mobileHeight;
        break;
      case DeviceType.tablet:
        width = tabletWidth ?? (mobileWidth != null ? mobileWidth! * 1.25 : null);
        height = tabletHeight ?? mobileHeight;
        break;
      case DeviceType.desktop:
        width = desktopWidth ?? tabletWidth ?? (mobileWidth != null ? mobileWidth! * 1.5 : null);
        height = desktopHeight ?? tabletHeight ?? mobileHeight;
        break;
    }
    
    // Eğer width yüzde olarak verilmişse (0-1 arası) ekran genişliğiyle çarp
    if (width != null && width > 0 && width < 1) {
      width = screenSize.width * width;
    }
    
    // Eğer height yüzde olarak verilmişse (0-1 arası) ekran yüksekliğiyle çarp
    if (height != null && height > 0 && height < 1) {
      height = screenSize.height * height;
    }
    
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      child: child,
    );
  }
}
