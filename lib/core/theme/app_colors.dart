import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDark = Color(0xFF00A884);

  // ── Backward-compat alias (folosit în statistics_screen etc.) ──
  static const Color secondary = accent; // = Color(0xFF00D4AA)

  // ── Semantic ────────────────────────────────────────────
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color success = Color(0xFF00D4AA);
  static const Color info = Color(0xFF40C4FF);

  // ── Dark theme backgrounds (forced dark) ───────────────
  static const Color background = Color(0xFF0D0D14);
  static const Color backgroundCard = Color(0xFF13131F);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF22223A);
  static const Color surfaceElevated = Color(0xFF252540);

  // ── Text ────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFF0EFFF);
  static const Color onSurfaceVariant = Color(0xFF9898B8);
  static const Color onSurfaceMuted = Color(0xFF5C5C80);

  // ── Borders ─────────────────────────────────────────────
  static const Color outline = Color(0xFF2E2E50);
  static const Color outlineLight = Color(0xFF3A3A60);

  // ── Chart / Action colors ───────────────────────────────
  static const Color chartBlue = Color(0xFF6C63FF);
  static const Color chartTeal = Color(0xFF00D4AA);
  static const Color chartOrange = Color(0xFFFF8C42);
  static const Color chartPink = Color(0xFFFF6B9D);
  static const Color chartYellow = Color(0xFFFFD166);
  static const Color chartRed = Color(0xFFFF5252);

  // ── Gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF13131F)],
  );

  static const LinearGradient vehicleCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252540), Color(0xFF1A1A2E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF6C63FF)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5252), Color(0xFFFF8C42)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D14), Color(0xFF0F0F1E)],
  );
}
