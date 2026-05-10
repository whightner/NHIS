import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/app_decorations.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/status_dot.dart';

/// Hero section: headline copy + CTA buttons + clinical dashboard visual.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final content = _HeroContent(isWide: isWide);
    const visual = ClinicalDashboardVisual();

    return Container(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 32 : 20,
              isWide ? 56 : 28,
              isWide ? 32 : 20,
              isWide ? 68 : 36,
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 11, child: content),
                      const SizedBox(width: 48),
                      const Expanded(flex: 10, child: visual),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content,
                      const SizedBox(height: 34),
                      visual,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Hero text + buttons ──────────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Pill(
          icon: Icons.verified_user_rounded,
          label: 'Secure nationwide healthcare platform',
        ),
        const SizedBox(height: 22),
        Text(
          'NHIS',
          style: isWide
              ? AppTextStyles.displayLarge
              : AppTextStyles.displaySmall,
        ),
        const SizedBox(height: 14),
        Text(
          'A unified digital health ecosystem for citizen identity, clinical '
          'records, care coordination, insurance verification, and health '
          'intelligence.',
          style: isWide ? AppTextStyles.bodyLarge : AppTextStyles.body,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_search_rounded),
              label: const Text('Verify patient'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(158, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.medical_information_rounded),
              label: const Text('Open health booklet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryMid,
                side: const BorderSide(color: AppColors.primaryMid),
                minimumSize: const Size(198, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const _TrustRow(),
      ],
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 14,
      runSpacing: 12,
      children: [
        _TrustSignal(icon: Icons.lock_rounded, label: 'Role-based access'),
        _TrustSignal(icon: Icons.hub_rounded, label: 'Connected facilities'),
        _TrustSignal(
          icon: Icons.monitor_heart_rounded,
          label: 'Continuity of care',
        ),
      ],
    );
  }
}

class _TrustSignal extends StatelessWidget {
  const _TrustSignal({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryMid, size: 19),
        const SizedBox(width: 7),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

// ── Clinical dashboard visual ────────────────────────────────────────────────

/// The mock clinical workspace displayed in the hero section.
class ClinicalDashboardVisual extends StatelessWidget {
  const ClinicalDashboardVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 480;
        return AspectRatio(
          aspectRatio: isCompact ? 0.72 : 1.03,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryPale,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MedicalNetworkPainter()),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: isCompact
                          ? const [
                              _VisualTopBar(),
                              SizedBox(height: 16),
                              Expanded(child: _PatientSummaryPanel()),
                              SizedBox(height: 14),
                              _CareTimelinePanel(),
                            ]
                          : const [
                              _VisualTopBar(),
                              SizedBox(height: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: _PatientSummaryPanel(),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(flex: 6, child: _VitalsPanel()),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14),
                              _CareTimelinePanel(),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Visual sub-panels ────────────────────────────────────────────────────────

class _VisualTopBar extends StatelessWidget {
  const _VisualTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: AppDecorations.panel(),
      child: const Row(
        children: [
          Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 27),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live care workspace',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.inkDarkest,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          StatusDot(color: AppColors.online),
          SizedBox(width: 6),
          Text(
            'Online',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientSummaryPanel extends StatelessWidget {
  const _PatientSummaryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient identity',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Verified across facilities',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _VisualMetric(label: 'EMR completeness', value: '92%'),
          const SizedBox(height: 10),
          const _ProgressBar(value: 0.92, color: AppColors.primary),
          const SizedBox(height: 16),
          const _VisualMetric(label: 'Open referrals', value: '3'),
          const SizedBox(height: 10),
          const _ProgressBar(value: 0.58, color: AppColors.secondary),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.primaryMid, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Authorized access only',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.inkMedium,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsPanel extends StatelessWidget {
  const _VitalsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.panel(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.monitor_heart_rounded, color: AppColors.danger, size: 32),
          SizedBox(height: 12),
          Text(
            'Clinical snapshot',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
          Spacer(),
          _DataRow(label: 'Visits', value: '12'),
          SizedBox(height: 10),
          _DataRow(label: 'Labs', value: '8'),
          SizedBox(height: 10),
          _DataRow(label: 'Rx', value: '5'),
        ],
      ),
    );
  }
}

class _CareTimelinePanel extends StatelessWidget {
  const _CareTimelinePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.panel(),
      child: const Row(
        children: [
          _TimelineNode(
            icon: Icons.badge_rounded,
            label: 'Verify',
            color: AppColors.primary,
          ),
          _TimelineDivider(),
          _TimelineNode(
            icon: Icons.medical_services_rounded,
            label: 'Consult',
            color: AppColors.secondary,
          ),
          _TimelineDivider(),
          _TimelineNode(
            icon: Icons.science_rounded,
            label: 'Results',
            color: AppColors.warning,
          ),
          _TimelineDivider(),
          _TimelineNode(
            icon: Icons.analytics_rounded,
            label: 'Report',
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: AppDecorations.tinted(color),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 16, height: 2, color: AppColors.borderMid);
  }
}

class _VisualMetric extends StatelessWidget {
  const _VisualMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, maxLines: 1, style: AppTextStyles.caption)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.inkDarkest,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyles.caption,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.inkDarkest,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: value,
        color: color,
        backgroundColor: AppColors.border,
      ),
    );
  }
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _MedicalNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.networkLine;

    final points = [
      Offset(size.width * 0.16, size.height * 0.24),
      Offset(size.width * 0.48, size.height * 0.15),
      Offset(size.width * 0.84, size.height * 0.27),
      Offset(size.width * 0.22, size.height * 0.76),
      Offset(size.width * 0.58, size.height * 0.84),
      Offset(size.width * 0.88, size.height * 0.68),
    ];

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        if ((i + j).isEven) canvas.drawLine(points[i], points[j], paint);
      }
    }

    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      fill.color = i.isEven ? AppColors.primary : AppColors.secondary;
      canvas.drawCircle(points[i], 5.5, fill);
      fill.color = Colors.white.withAlpha(180);
      canvas.drawCircle(points[i], 2.3, fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
