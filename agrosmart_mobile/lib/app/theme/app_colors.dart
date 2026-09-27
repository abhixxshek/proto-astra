import 'package:flutter/material.dart';

class AppColors {
  // Primary Agronomic Colors
  static const Color primary = Color(0xFF2E7D32); // Deep Emerald Green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  
  static const Color secondary = Color(0xFF00796B); // Teal Accent
  static const Color secondaryLight = Color(0xFF4DB6AC);
  
  static const Color accent = Color(0xFFFFA000); // Amber/Golden Harvest
  static const Color background = Color(0xFFF4F7F4); // Soft Light Mint
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1C2D1F);
  static const Color textSecondary = Color(0xFF556B58);
  static const Color textLight = Color(0xFF8E9E90);
  
  // Status Colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
  
  // Card Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF00796B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
