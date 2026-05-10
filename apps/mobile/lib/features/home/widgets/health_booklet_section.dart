import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/feature_card.dart';

/// Section describing the digital health booklet concept.
class HealthBookletSection extends StatelessWidget {
  const HealthBookletSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const heading = SectionHeading(
      eyebrow: 'Digital Health Booklet',
      title:
          'One longitudinal medical record for every authorized care journey.',
      description:
          'NHIS centralizes identity, visits, diagnoses, prescriptions, '
          'laboratory results, vaccinations, admissions, and treatment history '
          'so medical teams can make faster decisions with cleaner information.',
    );

    final content = Wrap(
      spacing: 14,
      runSpacing: 14,
      children: const [
        FeatureCard(
          icon: Icons.badge_rounded,
          title: 'Identity foundation',
          description:
              'Patient demographics, insurance references, facility links, '
              'and verification status kept consistent across care points.',
          color: AppColors.primary,
        ),
        FeatureCard(
          icon: Icons.description_rounded,
          title: 'Clinical memory',
          description:
              'Consultations, notes, diagnoses, prescriptions, and admissions '
              'remain attached to the same citizen health profile.',
          color: AppColors.secondary,
        ),
        FeatureCard(
          icon: Icons.biotech_rounded,
          title: 'Diagnostic continuity',
          description:
              'Laboratory and imaging results move from diagnostic services '
              'to clinicians without duplicate paper records.',
          color: AppColors.warning,
        ),
      ],
    );

    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 7, child: heading),
              const SizedBox(width: 42),
              Expanded(flex: 9, child: content),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 26), content],
          );
  }
}
