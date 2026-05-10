import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable [BoxDecoration] factories.
/// Keeps container styling consistent and DRY across the codebase.
abstract final class AppDecorations {
  /// Elevated white card — used in the hero visual panels.
  static BoxDecoration panel() => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: Color(0x140F172A),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Subtle grey card with a thin border — used for feature/capability cards.
  static BoxDecoration card() => BoxDecoration(
    color: AppColors.surfaceMuted,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.border),
  );

  /// Tinted background chip — used for timeline nodes, icon backgrounds, etc.
  static BoxDecoration tinted(Color color, {double radius = 8}) =>
      BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(radius),
      );

  /// Dark green summary block — used in the security section.
  static BoxDecoration darkGreen() => BoxDecoration(
    color: AppColors.primaryDeep,
    borderRadius: BorderRadius.circular(8),
  );
}
