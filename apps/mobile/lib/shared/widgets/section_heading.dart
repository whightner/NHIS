import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'pill.dart';

/// Standardised three-line section header:
/// [Pill eyebrow] → H1 title → body description.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(icon: Icons.add_circle_rounded, label: eyebrow),
        const SizedBox(height: 14),
        Text(title, style: AppTextStyles.h1),
        const SizedBox(height: 14),
        Text(description, style: AppTextStyles.body),
      ],
    );
  }
}
