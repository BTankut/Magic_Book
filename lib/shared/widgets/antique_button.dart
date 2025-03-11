import 'package:flutter/material.dart';
import 'package:magic_book/shared/constants/theme.dart';

/// Antik kitap temasına uygun özel buton widget'ı.
class AntiqueButton extends StatefulWidget {
  /// Buton metni.
  final String text;
  
  /// Buton tıklama olayı.
  final VoidCallback onPressed;
  
  /// Buton ikonu (isteğe bağlı).
  final IconData? icon;
  
  /// Butonun birincil mi ikincil mi olduğunu belirtir.
  /// Birincil butonlar daha belirgin renk ve gölgelere sahiptir.
  final bool isPrimary;
  
  /// Butonun genişliği (null ise mevcut alana sığacak şekilde genişler).
  final double? width;
  
  /// Butonun yüksekliği.
  final double height;
  
  /// Buton köşelerinin yuvarlaklık derecesi.
  final double borderRadius;
  
  /// Butonun metin rengi (özelleştirmek için).
  final Color? foregroundColor;
  
  const AntiqueButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.width,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.foregroundColor,
  });

  @override
  State<AntiqueButton> createState() => _AntiqueButtonState();
}

class _AntiqueButtonState extends State<AntiqueButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Buton renkleri
    final Color backgroundColor = widget.isPrimary 
        ? AppTheme.primaryColor 
        : Colors.transparent;
    
    final Color textColor = widget.foregroundColor ?? (widget.isPrimary 
        ? Colors.white 
        : AppTheme.primaryColor);
    
    final Color borderColor = AppTheme.primaryColor;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
              });
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() {
                _isPressed = false;
              });
              _animationController.reverse().then((_) {
                widget.onPressed();
              });
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
              _animationController.reverse();
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: 2.0,
                ),
                boxShadow: widget.isPrimary && !_isPressed
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
                image: widget.isPrimary
                    ? null
                    : null, // Eksik görsel yerine düz renk kullanıyoruz
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: textColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      widget.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
