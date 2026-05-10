import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';

/// Icon + title + description card used in section content grids.
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = math.min(360.0, MediaQuery.sizeOf(context).width - 40);
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 9),
            Text(description, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
