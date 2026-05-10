import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// Dark full-width band with 4 key impact metrics.
class ImpactStrip extends StatelessWidget {
  const ImpactStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 4 ? 2.45 : 2.2,
                  children: const [
                    _ImpactItem(value: '1', label: 'secure citizen identity'),
                    _ImpactItem(value: '360°', label: 'digital health booklet'),
                    _ImpactItem(value: '24/7', label: 'authorized access'),
                    _ImpactItem(value: '100%', label: 'auditable workflows'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  const _ImpactItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceMid,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textOnDarkMid,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
