import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The square NHIS logo icon used in headers and footers.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        color: Colors.white,
        size: size * 0.636,
      ),
    );
  }
}
