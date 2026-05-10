import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-width background band with a max-width constraint.
/// Wraps every landing-page section for consistent spacing.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surface,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 54),
            child: child,
          ),
        ),
      ),
    );
  }
}
