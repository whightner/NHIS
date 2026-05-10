import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Every [TextStyle] used in the NHIS mobile app lives here.
/// Adjust once → applies everywhere.
abstract final class AppTextStyles {
  // ── Display ────────────────────────────────────────────────────────────────
  static const displayLarge = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 64,
    height: 1.02,
    fontWeight: FontWeight.w900,
  );
  static const displaySmall = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 46,
    height: 1.02,
    fontWeight: FontWeight.w900,
  );

  // ── Headings ───────────────────────────────────────────────────────────────
  static const h1 = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w900,
  );
  static const h2 = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 26,
    height: 1.12,
    fontWeight: FontWeight.w900,
  );
  static const h3 = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    color: AppColors.inkMedium,
    fontSize: 21,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    color: AppColors.inkMuted,
    fontSize: 16,
    height: 1.52,
    fontWeight: FontWeight.w600,
  );
  static const bodySmall = TextStyle(
    color: AppColors.inkMuted,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    color: AppColors.inkLight,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  static const labelLarge = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
  static const label = TextStyle(
    color: AppColors.inkDarkest,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );
  static const labelSmall = TextStyle(
    color: AppColors.inkMuted,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // ── Nav ────────────────────────────────────────────────────────────────────
  static const navItem = TextStyle(
    color: AppColors.inkMuted,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // ── Metric / dashboard ─────────────────────────────────────────────────────
  static const metricValue = TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.w900,
  );
  static const metricLabel = TextStyle(
    color: AppColors.textOnDarkMid,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // ── Pill badge ─────────────────────────────────────────────────────────────
  static const pillText = TextStyle(
    color: AppColors.pillText,
    fontSize: 12,
    fontWeight: FontWeight.w900,
  );
}
