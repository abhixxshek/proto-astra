import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  glass,
  tinted,
}

/// iOS-styled Interactive Pill Glass Button
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? customColor;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.padding,
    this.customColor,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color textColor;
    BoxDecoration decoration;

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        textColor = Colors.white;
        decoration = BoxDecoration(
          gradient: isEnabled
              ? (widget.customColor != null
                  ? LinearGradient(colors: [widget.customColor!, widget.customColor!.withValues(alpha: 0.85)])
                  : AppColors.primaryGradient)
              : null,
          color: isEnabled ? null : Colors.grey.shade300,
          borderRadius: AppGlass.borderRadiusPill,
          boxShadow: isEnabled ? AppGlass.emeraldGlow : null,
        );
        break;

      case GlassButtonVariant.secondary:
        textColor = AppColors.textPrimary;
        decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: AppGlass.borderRadiusPill,
          border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
          boxShadow: AppGlass.softShadow,
        );
        break;

      case GlassButtonVariant.glass:
        textColor = widget.customColor ?? AppColors.primary;
        decoration = BoxDecoration(
          color: AppColors.glassFillLight,
          borderRadius: AppGlass.borderRadiusPill,
          border: Border.all(color: AppColors.glassBorderLight, width: 1.2),
          boxShadow: AppGlass.softShadow,
        );
        break;

      case GlassButtonVariant.tinted:
        final base = widget.customColor ?? AppColors.primary;
        textColor = base;
        decoration = BoxDecoration(
          color: base.withValues(alpha: 0.12),
          borderRadius: AppGlass.borderRadiusPill,
          border: Border.all(color: base.withValues(alpha: 0.25), width: 1.0),
        );
        break;
    }

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: decoration,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: textColor),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          style: AppTypography.button.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
