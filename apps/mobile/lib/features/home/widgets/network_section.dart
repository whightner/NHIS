import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/section_heading.dart';

/// Section showing NHIS as the hub of a connected healthcare network.
class NetworkSection extends StatelessWidget {
  const NetworkSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    const map = _NetworkMap();
    const heading = SectionHeading(
      eyebrow: 'Connected health network',
      title:
          'Hospitals, clinics, labs, pharmacies, insurers, employers, and '
          'patients in one controlled ecosystem.',
      description:
          'The platform reduces fragmented records, simplifies verification, '
          'accelerates referrals, and gives authorized institutions the right '
          'data at the right moment.',
    );

    return isWide
        ? const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 8, child: map),
            SizedBox(width: 46),
            Expanded(flex: 7, child: heading),
          ],
        )
        : const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, SizedBox(height: 28), map],
        );
  }
}

// ── Network map ──────────────────────────────────────────────────────────────

class _NetworkMap extends StatelessWidget {
  const _NetworkMap();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderBlue),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _ConnectionPainter())),
            const Align(
              alignment: Alignment.center,
              child: NetworkNode(
                icon: Icons.health_and_safety_rounded,
                title: 'NHIS',
                color: AppColors.primary,
                size: 100,
              ),
            ),
            const Align(
              alignment: Alignment(-0.78, -0.62),
              child: NetworkNode(
                icon: Icons.local_hospital_rounded,
                title: 'Hospitals',
                color: AppColors.secondary,
              ),
            ),
            const Align(
              alignment: Alignment(0.74, -0.58),
              child: NetworkNode(
                icon: Icons.science_rounded,
                title: 'Labs',
                color: AppColors.warning,
              ),
            ),
            const Align(
              alignment: Alignment(-0.72, 0.58),
              child: NetworkNode(
                icon: Icons.local_pharmacy_rounded,
                title: 'Pharmacies',
                color: AppColors.pink,
              ),
            ),
            const Align(
              alignment: Alignment(0.74, 0.56),
              child: NetworkNode(
                icon: Icons.policy_rounded,
                title: 'Insurers',
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A coloured square node used in the network map.
class NetworkNode extends StatelessWidget {
  const NetworkNode({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.size = 84,
  });

  final IconData icon;
  final String title;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: size > 90 ? 34 : 28),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final points = [
      Offset(size.width * 0.22, size.height * 0.19),
      Offset(size.width * 0.78, size.height * 0.20),
      Offset(size.width * 0.24, size.height * 0.79),
      Offset(size.width * 0.78, size.height * 0.78),
    ];

    final paint =
        Paint()
          ..color = AppColors.networkLine
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    for (final point in points) {
      final path =
          Path()
            ..moveTo(center.dx, center.dy)
            ..quadraticBezierTo(
              (center.dx + point.dx) / 2,
              center.dy + (point.dy > center.dy ? 30 : -30),
              point.dx,
              point.dy,
            );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
