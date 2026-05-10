import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/brand_mark.dart';

/// Landing-page navigation bar with brand mark, nav items, and login button.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.isWide,
    required this.onLoginTap,
  });

  final bool isWide;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 20,
              vertical: isWide ? 20 : 16,
            ),
            child: Row(
              children: [
                const BrandMark(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'National Health Information System',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge,
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(width: 24),
                  const _NavItem(label: 'Digital records'),
                  const _NavItem(label: 'Care network'),
                  const _NavItem(label: 'Secure access'),
                ],
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onLoginTap,
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(isWide ? 'Access portal' : 'Login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(96, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(label, style: AppTextStyles.navItem),
    );
  }
}
