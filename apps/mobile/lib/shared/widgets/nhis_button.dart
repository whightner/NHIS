import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// NHIS-branded filled (primary) button.
class NhisFilledButton extends StatelessWidget {
  const NhisFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minWidth = 140,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double minWidth;
  final bool loading;

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: Size(minWidth, 48),
      shape: _shape,
    );

    final child =
        loading
            ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
            : icon != null
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
            : Text(label);

    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}

/// NHIS-branded outlined (secondary) button.
class NhisOutlinedButton extends StatelessWidget {
  const NhisOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minWidth = 140,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double minWidth;

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryMid,
      side: const BorderSide(color: AppColors.primaryMid),
      minimumSize: Size(minWidth, 48),
      shape: _shape,
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: style,
      );
    }

    return OutlinedButton(onPressed: onPressed, style: style, child: Text(label));
  }
}
