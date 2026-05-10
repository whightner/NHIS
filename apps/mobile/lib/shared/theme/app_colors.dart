import 'package:flutter/material.dart';

/// Every colour used in the NHIS mobile app lives here.
/// Import this class wherever a [Color] literal would have appeared.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF047857);
  static const primaryLight = Color(0xFFD1FAE5);
  static const primaryDeep  = Color(0xFF064E3B);
  static const primaryMid   = Color(0xFF0F766E);

  // ── Secondary (blue) ───────────────────────────────────────────────────────
  static const secondary      = Color(0xFF1D4ED8);
  static const secondaryLight = Color(0xFFEFF6FF);
  static const secondaryPale  = Color(0xFFDBEAFE);
  static const borderBlue     = Color(0xFFBFDBFE);
  static const networkLine    = Color(0xFF93C5FD);

  // ── Accent ─────────────────────────────────────────────────────────────────
  static const warning = Color(0xFFF59E0B);
  static const danger  = Color(0xFFDC2626);
  static const purple  = Color(0xFF7C3AED);
  static const pink    = Color(0xFFDB2777);
  static const online  = Color(0xFF10B981);

  // ── Ink / text ─────────────────────────────────────────────────────────────
  static const inkDarkest = Color(0xFF0F172A);
  static const inkDark    = Color(0xFF1E293B);
  static const inkMedium  = Color(0xFF334155);
  static const inkMuted   = Color(0xFF475569);
  static const inkLight   = Color(0xFF64748B);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border    = Color(0xFFE2E8F0);
  static const borderMid = Color(0xFFCBD5E1);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const surface         = Colors.white;
  static const surfaceMuted    = Color(0xFFF8FAFC);
  static const background      = Color(0xFFF7FAFC);
  static const backgroundGreen = Color(0xFFECFDF5);
  static const backgroundBlue  = Color(0xFFEFF6FF);
  static const darkSurface     = Color(0xFF0F172A);
  static const darkSurfaceMid  = Color(0xFF1E293B);

  // ── Text on dark backgrounds ───────────────────────────────────────────────
  static const textOnDark    = Color(0xFFE2E8F0);
  static const textOnDarkMid = Color(0xFFCBD5E1);
  static const textOnGreen   = Color(0xFFD1FAE5);
  static const pillText      = Color(0xFF065F46);
}
