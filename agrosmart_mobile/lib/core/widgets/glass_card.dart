import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';

/// Premium iOS Frosted Glass Card with BackdropFilter and Specular Border
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Border? border;
  final List<BoxShadow>? shadows;
  final double blur;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.fillColor,
    this.border,
    this.shadows,
    this.blur = AppGlass.blurStandard,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppGlass.borderRadiusLg;

    Widget cardBody = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.glassFillCard,
            gradient: gradient,
            borderRadius: effectiveRadius,
            border: border ??
                Border.all(
                  color: AppColors.glassBorderLight,
                  width: 1.0,
                ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      cardBody = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: cardBody,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows ?? AppGlass.softShadow,
      ),
      child: cardBody,
    );
  }
}
