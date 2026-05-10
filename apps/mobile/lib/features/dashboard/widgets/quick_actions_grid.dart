import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Grid of quick-action shortcut buttons.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = [
    _ActionData(
      icon: Icons.person_search_rounded,
      label: 'Vérifier un patient',
      color: AppColors.primary,
    ),
    _ActionData(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scanner un UHID',
      color: AppColors.secondary,
    ),
    _ActionData(
      icon: Icons.medical_information_rounded,
      label: 'Ouvrir un dossier',
      color: AppColors.warning,
    ),
    _ActionData(
      icon: Icons.add_circle_outline_rounded,
      label: 'Nouvelle consultation',
      color: AppColors.purple,
    ),
    _ActionData(
      icon: Icons.science_rounded,
      label: 'Résultats de labo',
      color: AppColors.pink,
    ),
    _ActionData(
      icon: Icons.analytics_rounded,
      label: 'Rapports & Analytics',
      color: AppColors.primaryMid,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children:
              _actions.map((a) => _ActionTile(data: a)).toList(),
        );
      },
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: wire to feature routes.
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: data.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.inkDarkest,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
