import 'package:flutter/material.dart';

/// Centralized color palette for the application
/// Maintains consistency across all UI components
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors (mapped)
  static const Color primary = Color(0xFFEFC45D);
  static const Color primaryLight = Color(0xFFF1BF64);
  static const Color primaryDark = Color(0xFFEE9C70);

  // Secondary colors (kept as-is)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent colors (mapped where possible)
  static const Color accent = Color(0xFFEFA35F);
  static const Color accentLight = Color(0xFFF1BF64);
  static const Color accentDark = Color(0xFFEE9C70);

  // Background colors (mapped)
  static const Color backgroundLight = Color(0xFFF7F3F2);
  static const Color backgroundDark = Color(0xFF1F2937); // kept
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);

  // Text colors (mapped)
  static const Color textPrimary = Color(0xFF090909);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFF8A8A8A);

  // Status colors (mapped)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEFA35F);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6); // kept

  // Role-specific colors (kept as-is)
  static const Color admin = Color(0xFF8B5CF6);
  static const Color teacher = Color(0xFF06B6D4);
  static const Color student = Color(0xFFEC4899);

  // Neutral colors (kept as-is)
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Border colors (mapped)
  static const Color border = Color(0xFFF7F3F2);
  static const Color borderDark = Color(0xFF374151);

  // Divider colors (mapped)
  static const Color divider = Color(0xFFF7F3F2);
  static const Color dividerDark = Color(0xFF374151);
}
