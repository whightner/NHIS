import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/brand_mark.dart';

/// Dark footer bar at the bottom of the landing page.
class FooterBand extends StatelessWidget {
  const FooterBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            child: Row(
              children: [
                const BrandMark(),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'NHIS brings identity, healthcare delivery, medical '
                    'records, insurance workflows, analytics, and compliance '
                    'into one secure national platform.',
                    style: TextStyle(
                      color: AppColors.textOnDark,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
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
