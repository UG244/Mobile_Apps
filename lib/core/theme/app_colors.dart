import 'package:flutter/material.dart';

/// Centralized Color Palette untuk BlueMart Retail.
///
/// Menggunakan nuansa Deep Navy Blue untuk kesan profesional & terpercaya,
/// dipadukan dengan Electric Blue & Vibrant Orange untuk aksen CTA yang modern.
class AppColors {
  AppColors._();

  // Primary - Deep Navy Blue
  static const Color primary = Color(0xFF0F172A);
  static const Color primaryLight = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF020617);

  // Accent / CTA - Electric Blue & Vibrant Orange
  static const Color accent = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentOrange = Color(0xFFF97316);

  // Neutral Colors (Background & Surfaces)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Subtle Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
