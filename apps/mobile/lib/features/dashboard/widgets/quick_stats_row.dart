import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Row of 4 quick-stat cards at the top of the dashboard.
/// Replace the mock [items] list with real API data when ready.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key});

  // TODO: Replace with real data from API.
  static const _items = [
    _StatData(
      icon: Icons.person_search_rounded,
      value: '12',
      label: 'Vérifiés aujourd\'hui',
      color: AppColors.primary,
    ),
    _StatData(
      icon: Icons.folder_open_rounded,
      value: '5',
      label: 'Dossiers ouverts',
      color: AppColors.secondary,
    ),
    _StatData(
      icon: Icons.pending_actions_rounded,
      value: '3',
      label: 'Tâches en attente',
      color: AppColors.warning,
    ),
    _StatData(
      icon: Icons.local_hospital_rounded,
      value: '8',
      label: 'Établissements actifs',
      color: AppColors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.55 : 1.45,
          children: _items.map((d) => _StatCard(data: d)).toList(),
        );
      },
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────

class _StatData {
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const Spacer(),
          Text(
            data.value,
            style: TextStyle(
              color: data.color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
