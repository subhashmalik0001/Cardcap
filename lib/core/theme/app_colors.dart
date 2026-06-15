import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFFF0F0F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceInput = Color(0xFFF5F5F5);

  // ── Brand ──
  static const Color primary = Color(0xFF6A3EEB);
  static const Color primaryLight = Color(0xFFEDE8FC);
  static const Color primarySoft = Color(0xFF8B68F0);

  // ── Text ──
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const Color success = Color(0xFF12A664);
  static const Color error = Color(0xFFE84040);

  // ── Borders ──
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // ── Wallet card gradient ──
  static const Color walletGradientStart = Color(0xFF8B68F0);
  static const Color walletGradientEnd = Color(0xFF5B2FD4);

  static const LinearGradient walletGradient = LinearGradient(
    colors: [walletGradientStart, walletGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Badge backgrounds ──
  static const Color successBadgeBg = Color(0xFFE6F7EF);
  static const Color errorBadgeBg = Color(0xFFFFEBEB);

  // ── Shadows ──
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x14000000),
          blurRadius: 20,
          spreadRadius: 0,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        const BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 32,
          spreadRadius: 0,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get fabShadow => [
        const BoxShadow(
          color: Color(0x336A3EEB),
          blurRadius: 16,
          spreadRadius: 0,
          offset: Offset(0, 4),
        ),
      ];
}
