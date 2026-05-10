import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/app_decorations.dart';
import '../../../shared/widgets/section_heading.dart';

/// Section showcasing four operational capabilities of NHIS.
class CapabilitySection extends StatelessWidget {
  const CapabilitySection({super.key, required this.isWide});

  final bool isWide;

  static const _tiles = [
    _CapabilityTile(
      icon: Icons.person_search_rounded,
      title: 'Fast verification',
      description:
          'Confirm a patient identity and membership status before care '
          'delivery.',
    ),
    _CapabilityTile(
      icon: Icons.route_rounded,
      title: 'Digital workflows',
      description:
          'Move registration, consultation, diagnostics, prescriptions, and '
          'claims through controlled steps.',
    ),
    _CapabilityTile(
      icon: Icons.tips_and_updates_rounded,
      title: 'Smart assistance',
      description:
          'Support clinicians with structured context, previous history, and '
          'decision prompts.',
    ),
    _CapabilityTile(
      icon: Icons.analytics_rounded,
      title: 'Analytics and fraud monitoring',
      description:
          'Surface operational trends, unusual activity, compliance gaps, and '
          'service utilization.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          eyebrow: 'Operational intelligence',
          title: 'The home for daily healthcare operations and national reporting.',
          description:
              'NHIS is not only a medical record. It is the operational layer '
              'that helps institutions coordinate activities, improve service '
              'quality, and protect public health data.',
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 2.9 : 1.2,
              children: _tiles,
            );
          },
        ),
      ],
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  const _CapabilityTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryMid, size: 30),
          const SizedBox(height: 12),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Expanded(
            child: Text(description, maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.inkMuted,
                  height: 1.38,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
