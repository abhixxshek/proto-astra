import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Glassmorphic Design System Tokens for AgroSmart (iOS Style)
class AppGlass {
  // Blur Intensities
  static const double blurSubtle = 10.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 28.0;

  // Corner Radii (Smooth Apple-style curves)
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 18.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(radiusFull);

  // Soft Layered Shadows (iOS Style, avoids harsh Android drop shadows)
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> emeraldGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.22),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // Glass BoxDecorations
  static BoxDecoration cardDecoration({
    BorderRadius? borderRadius,
    Color? fillColor,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: fillColor ?? AppColors.glassFillCard,
      borderRadius: borderRadius ?? borderRadiusLg,
      border: border ??
          Border.all(
            color: AppColors.glassBorderLight,
            width: 1.0,
          ),
      boxShadow: shadows ?? softShadow,
    );
  }

  static BoxDecoration floatingBarDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: borderRadius ?? borderRadiusXl,
      border: Border.all(
        color: AppColors.glassBorderLight,
        width: 1.2,
      ),
      boxShadow: floatingShadow,
    );
  }

  static BoxDecoration buttonGlassDecoration({
    bool isPrimary = true,
    BorderRadius? borderRadius,
  }) {
    if (isPrimary) {
      return BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadius ?? borderRadiusPill,
        boxShadow: emeraldGlow,
      );
    }
    return BoxDecoration(
      color: AppColors.glassFillLight,
      borderRadius: borderRadius ?? borderRadiusPill,
      border: Border.all(
        color: AppColors.glassBorderSubtle,
        width: 1.0,
      ),
    );
  }
}
