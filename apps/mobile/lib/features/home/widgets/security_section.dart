import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/app_decorations.dart';

/// Section highlighting NHIS security model.
class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const checklist = Column(
      children: [
        _SecurityLine(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Role-based permissions',
          description:
              'Admins, operators, verifiers, auditors, nurses, and patients '
              'receive access aligned with their responsibilities.',
        ),
        _SecurityLine(
          icon: Icons.history_rounded,
          title: 'Traceable activity',
          description:
              'Sensitive actions are auditable so compliance teams can review '
              'who accessed or changed information.',
        ),
        _SecurityLine(
          icon: Icons.sync_lock_rounded,
          title: 'Controlled sharing',
          description:
              'Institutions exchange information through authorization rules '
              'instead of informal file transfers.',
        ),
      ],
    );

    const summary = _SecuritySummaryCard();

    return isWide
        ? const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: summary),
              SizedBox(width: 30),
              Expanded(flex: 8, child: checklist),
            ],
          )
        : const Column(children: [summary, SizedBox(height: 22), checklist]);
  }
}

class _SecuritySummaryCard extends StatelessWidget {
  const _SecuritySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.darkGreen(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gpp_good_rounded, color: AppColors.textOnGreen, size: 42),
          SizedBox(height: 18),
          Text(
            'Security is part of the care model.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'The system must protect national health data while still making '
            'essential information available during authorized care workflows.',
            style: TextStyle(
              color: AppColors.textOnGreen,
              fontSize: 15,
              height: 1.48,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityLine extends StatelessWidget {
  const _SecurityLine({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: AppColors.inkDarkest,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 5),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
