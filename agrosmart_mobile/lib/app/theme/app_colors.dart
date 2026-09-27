import 'package:flutter/material.dart';

/// Comprehensive iOS-inspired Color System for AgroSmart.
/// Blends high-end Apple neutrals with agricultural emerald/forest accents.
class AppColors {
  // Primary iOS Emerald / Forest Palette
  static const Color primary = Color(0xFF1E6F3D);       // Apple Forest Green
  static const Color primaryLight = Color(0xFF34C759);  // Apple System Green
  static const Color primaryDark = Color(0xFF0F4D27);   // Deep Pine
  static const Color primaryMuted = Color(0xFFE8F5E9);  // Very soft tint

  // iOS System Accent Accents (For distinct analytical categories)
  static const Color iosTeal = Color(0xFF30B0C7);
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosIndigo = Color(0xFF5856D6);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosRed = Color(0xFFFF3B30);

  // Agronomic accents
  static const Color secondary = Color(0xFF00875A);     // Rich Sage Teal
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color accent = Color(0xFFD97706);        // Golden Harvest Amber

  // iOS Backgrounds & Surfaces
  static const Color background = Color(0xFFF2F5F3);    // Subtle soft sage-tinted neutral
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8FAF8);

  // Glassmorphic Surface Fills
  static const Color glassFill = Color(0xD9FFFFFF);           // 85% opacity frosted white
  static const Color glassFillLight = Color(0x99FFFFFF);      // 60% opacity white
  static const Color glassFillCard = Color(0xB8FFFFFF);       // 72% opacity white
  static const Color glassFillDark = Color(0xCC111813);       // Frosted dark slate

  // Glassmorphic Borders & Highlights
  static const Color glassBorderLight = Color(0x80FFFFFF);    // 50% white specular highlight
  static const Color glassBorderSubtle = Color(0x1F000000);   // 12% black contour
  static const Color glassBorderActive = Color(0x661E6F3D);   // 40% primary green border

  // Text Hierarchy (Apple Human Interface Guidelines)
  static const Color textPrimary = Color(0xFF111813);         // Label (High contrast)
  static const Color textSecondary = Color(0xFF5B695E);       // Secondary Label
  static const Color textTertiary = Color(0xFF8F9E92);        // Tertiary Label
  static const Color textQuaternary = Color(0xFFB5C2B7);      // Quaternary Label

  // Semantic Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Legacy compatibility getters
  static const Color cardBg = Colors.white;
  static const Color textLight = Color(0xFF8F9E92);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E6F3D), Color(0xFF0F4D27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F4D27), Color(0xFF1E6F3D), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xE6FFFFFF), Color(0xB3FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0xF2FFFFFF), Color(0xCCFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1E6F3D), Color(0xFF00875A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
