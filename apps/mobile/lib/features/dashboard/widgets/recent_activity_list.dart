import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Recent activity feed. Replace mock data with real API calls when ready.
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  // TODO: fetch from API.
  static final _items = [
    _ActivityItem(
      icon: Icons.verified_user_rounded,
      title: 'Patient vérifié',
      subtitle: 'NHIS-CM-2024-004812 · Consultation générale',
      time: 'Il y a 3 min',
      color: AppColors.primary,
    ),
    _ActivityItem(
      icon: Icons.science_rounded,
      title: 'Résultat de laboratoire reçu',
      subtitle: 'Analyse sanguine NFS — Dossier #00312',
      time: 'Il y a 18 min',
      color: AppColors.warning,
    ),
    _ActivityItem(
      icon: Icons.description_rounded,
      title: 'Dossier ouvert',
      subtitle: 'NHIS-CM-2024-001944 · Suivi post-opératoire',
      time: 'Il y a 35 min',
      color: AppColors.secondary,
    ),
    _ActivityItem(
      icon: Icons.medication_rounded,
      title: 'Ordonnance générée',
      subtitle: 'Paracétamol 500mg × 14 jours',
      time: 'Il y a 1 h',
      color: AppColors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 8),
                Text('Activité récente', style: AppTextStyles.labelLarge),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._items.map((item) => _ActivityRow(item: item)),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.label),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(item.time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
