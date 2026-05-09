import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const NhisMobileApp());
}

class NhisMobileApp extends StatelessWidget {
  const NhisMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF047857),
          primary: const Color(0xFF047857),
          secondary: const Color(0xFF1D4ED8),
          tertiary: const Color(0xFFF59E0B),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const NhisHomePage(),
    );
  }
}

class NhisHomePage extends StatelessWidget {
  const NhisHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HomeHeader(isWide: isWide)),
                SliverToBoxAdapter(child: _HeroSection(isWide: isWide)),
                const SliverToBoxAdapter(child: _ImpactStrip()),
                SliverToBoxAdapter(
                  child: _SectionShell(
                    child: _HealthBookletSection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionShell(
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: _NetworkSection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionShell(
                    child: _CapabilitySection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionShell(
                    backgroundColor: const Color(0xFFECFDF5),
                    child: _SecuritySection(isWide: isWide),
                  ),
                ),
                const SliverToBoxAdapter(child: _FooterBand()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                const _BrandMark(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'National Health Information System',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(width: 24),
                  const _HeaderItem(label: 'Digital records'),
                  const _HeaderItem(label: 'Care network'),
                  const _HeaderItem(label: 'Secure access'),
                ],
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(isWide ? 'Access portal' : 'Login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF047857),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.health_and_safety_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  const _HeaderItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Pill(
          icon: Icons.verified_user_rounded,
          label: 'Secure nationwide healthcare platform',
        ),
        const SizedBox(height: 22),
        Text(
          'NHIS',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: isWide ? 64 : 46,
            height: 1.02,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A unified digital health ecosystem for citizen identity, clinical records, care coordination, insurance verification, and health intelligence.',
          style: TextStyle(
            color: const Color(0xFF334155),
            fontSize: isWide ? 21 : 18,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
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
                backgroundColor: const Color(0xFF047857),
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
                foregroundColor: const Color(0xFF0F766E),
                side: const BorderSide(color: Color(0xFF0F766E)),
                minimumSize: const Size(198, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const _HeroTrustRow(),
      ],
    );

    final visual = const _ClinicalDashboardVisual();

    return Container(
      color: const Color(0xFFF7FAFC),
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
            child:
                isWide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 11, child: content),
                        const SizedBox(width: 48),
                        Expanded(flex: 10, child: visual),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [content, const SizedBox(height: 34), visual],
                    ),
          ),
        ),
      ),
    );
  }
}

class _HeroTrustRow extends StatelessWidget {
  const _HeroTrustRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      children: const [
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
        Icon(icon, color: const Color(0xFF0F766E), size: 19),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ClinicalDashboardVisual extends StatelessWidget {
  const _ClinicalDashboardVisual();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 480;

        return AspectRatio(
          aspectRatio: isCompact ? 0.72 : 1.03,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
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
                      children:
                          isCompact
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

class _VisualTopBar extends StatelessWidget {
  const _VisualTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(
            Icons.local_hospital_rounded,
            color: Color(0xFF047857),
            size: 27,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live care workspace',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          _StatusDot(color: Color(0xFF10B981)),
          SizedBox(width: 6),
          Text(
            'Online',
            style: TextStyle(
              color: Color(0xFF047857),
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
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFFD1FAE5),
                child: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF047857),
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
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Verified across facilities',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _VisualMetric(label: 'EMR completeness', value: '92%'),
          const SizedBox(height: 10),
          const _ProgressLine(value: 0.92, color: Color(0xFF047857)),
          const SizedBox(height: 16),
          const _VisualMetric(label: 'Open referrals', value: '3'),
          const SizedBox(height: 10),
          const _ProgressLine(value: 0.58, color: Color(0xFF1D4ED8)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_rounded, color: Color(0xFF0F766E), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Authorized access only',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF334155),
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
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.monitor_heart_rounded, color: Color(0xFFDC2626), size: 32),
          SizedBox(height: 12),
          Text(
            'Clinical snapshot',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Spacer(),
          _SmallDataRow(label: 'Visits', value: '12'),
          SizedBox(height: 10),
          _SmallDataRow(label: 'Labs', value: '8'),
          SizedBox(height: 10),
          _SmallDataRow(label: 'Rx', value: '5'),
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
      decoration: _panelDecoration(),
      child: Row(
        children: const [
          _TimelineNode(
            icon: Icons.badge_rounded,
            label: 'Verify',
            color: Color(0xFF047857),
          ),
          _TimelineLine(),
          _TimelineNode(
            icon: Icons.medical_services_rounded,
            label: 'Consult',
            color: Color(0xFF1D4ED8),
          ),
          _TimelineLine(),
          _TimelineNode(
            icon: Icons.science_rounded,
            label: 'Results',
            color: Color(0xFFF59E0B),
          ),
          _TimelineLine(),
          _TimelineNode(
            icon: Icons.analytics_rounded,
            label: 'Report',
            color: Color(0xFF7C3AED),
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
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 16, height: 2, color: const Color(0xFFCBD5E1));
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
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SmallDataRow extends StatelessWidget {
  const _SmallDataRow({required this.label, required this.value});

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
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.value, required this.color});

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
        backgroundColor: const Color(0xFFE2E8F0),
      ),
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x140F172A), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );
}

class _MedicalNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFF93C5FD);

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
        if ((i + j).isEven) {
          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }

    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      fill.color = i.isEven ? const Color(0xFF047857) : const Color(0xFF1D4ED8);
      canvas.drawCircle(points[i], 5.5, fill);
      fill.color = Colors.white.withAlpha(180);
      canvas.drawCircle(points[i], 2.3, fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
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
        color: const Color(0xFF1E293B),
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
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.child,
    this.backgroundColor = Colors.white,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 54),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _HealthBookletSection extends StatelessWidget {
  const _HealthBookletSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final heading = const _SectionHeading(
      eyebrow: 'Digital Health Booklet',
      title:
          'One longitudinal medical record for every authorized care journey.',
      description:
          'NHIS centralizes identity, visits, diagnoses, prescriptions, laboratory results, vaccinations, admissions, and treatment history so medical teams can make faster decisions with cleaner information.',
    );

    final content = Wrap(
      spacing: 14,
      runSpacing: 14,
      children: const [
        _FeatureCard(
          icon: Icons.badge_rounded,
          title: 'Identity foundation',
          description:
              'Patient demographics, insurance references, facility links, and verification status are kept consistent across care points.',
          color: Color(0xFF047857),
        ),
        _FeatureCard(
          icon: Icons.description_rounded,
          title: 'Clinical memory',
          description:
              'Consultations, notes, diagnoses, prescriptions, and admissions remain attached to the same citizen health profile.',
          color: Color(0xFF1D4ED8),
        ),
        _FeatureCard(
          icon: Icons.biotech_rounded,
          title: 'Diagnostic continuity',
          description:
              'Laboratory and imaging results can move from diagnostic services to clinicians without duplicate paper records.',
          color: Color(0xFFF59E0B),
        ),
      ],
    );

    return isWide
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: heading),
            const SizedBox(width: 42),
            Expanded(flex: 9, child: content),
          ],
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, const SizedBox(height: 26), content],
        );
  }
}

class _NetworkSection extends StatelessWidget {
  const _NetworkSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final map = const _ConnectedNetworkMap();
    final heading = const _SectionHeading(
      eyebrow: 'Connected health network',
      title:
          'Hospitals, clinics, labs, pharmacies, insurers, employers, and patients in one controlled ecosystem.',
      description:
          'The platform is designed to reduce fragmented records, simplify verification, accelerate referrals, and give authorized institutions the right data at the right moment.',
    );

    return isWide
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 8, child: map),
            const SizedBox(width: 46),
            Expanded(flex: 7, child: heading),
          ],
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, const SizedBox(height: 28), map],
        );
  }
}

class _ConnectedNetworkMap extends StatelessWidget {
  const _ConnectedNetworkMap();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _ConnectionPainter())),
            const Align(
              alignment: Alignment.center,
              child: _NetworkNode(
                icon: Icons.health_and_safety_rounded,
                title: 'NHIS',
                color: Color(0xFF047857),
                size: 100,
              ),
            ),
            const Align(
              alignment: Alignment(-0.78, -0.62),
              child: _NetworkNode(
                icon: Icons.local_hospital_rounded,
                title: 'Hospitals',
                color: Color(0xFF1D4ED8),
              ),
            ),
            const Align(
              alignment: Alignment(0.74, -0.58),
              child: _NetworkNode(
                icon: Icons.science_rounded,
                title: 'Labs',
                color: Color(0xFFF59E0B),
              ),
            ),
            const Align(
              alignment: Alignment(-0.72, 0.58),
              child: _NetworkNode(
                icon: Icons.local_pharmacy_rounded,
                title: 'Pharmacies',
                color: Color(0xFFDB2777),
              ),
            ),
            const Align(
              alignment: Alignment(0.74, 0.56),
              child: _NetworkNode(
                icon: Icons.policy_rounded,
                title: 'Insurers',
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkNode extends StatelessWidget {
  const _NetworkNode({
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
      Offset(size.width * 0.78, size.height * 0.2),
      Offset(size.width * 0.24, size.height * 0.79),
      Offset(size.width * 0.78, size.height * 0.78),
    ];

    final paint =
        Paint()
          ..color = const Color(0xFF93C5FD)
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

class _CapabilitySection extends StatelessWidget {
  const _CapabilitySection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _CapabilityTile(
        icon: Icons.person_search_rounded,
        title: 'Fast verification',
        description:
            'Confirm a patient identity and membership status before care delivery.',
      ),
      _CapabilityTile(
        icon: Icons.route_rounded,
        title: 'Digital workflows',
        description:
            'Move registration, consultation, diagnostics, prescriptions, and claims through controlled steps.',
      ),
      _CapabilityTile(
        icon: Icons.tips_and_updates_rounded,
        title: 'Smart assistance',
        description:
            'Support clinicians with structured context, previous history, and decision prompts.',
      ),
      _CapabilityTile(
        icon: Icons.analytics_rounded,
        title: 'Analytics and fraud monitoring',
        description:
            'Surface operational trends, unusual activity, compliance gaps, and service utilization.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          eyebrow: 'Operational intelligence',
          title:
              'The home for daily healthcare operations and national reporting.',
          description:
              'NHIS is not only a medical record. It is also the operational layer that helps institutions coordinate activities, improve service quality, and protect public health data.',
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 900
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
              children: cards,
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E), size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                height: 1.38,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final checklist = Column(
      children: const [
        _SecurityLine(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Role-based permissions',
          description:
              'Admins, operators, verifiers, auditors, nurses, and patients receive access aligned with their responsibilities.',
        ),
        _SecurityLine(
          icon: Icons.history_rounded,
          title: 'Traceable activity',
          description:
              'Sensitive actions should be auditable so compliance teams can review who accessed or changed information.',
        ),
        _SecurityLine(
          icon: Icons.sync_lock_rounded,
          title: 'Controlled sharing',
          description:
              'Institutions exchange information through authorization rules instead of informal file transfers.',
        ),
      ],
    );

    final summary = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gpp_good_rounded, color: Color(0xFFA7F3D0), size: 42),
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
            'The system must protect national health data while still making essential information available during authorized care workflows.',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 15,
              height: 1.48,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return isWide
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: summary),
            const SizedBox(width: 30),
            Expanded(flex: 8, child: checklist),
          ],
        )
        : Column(children: [summary, const SizedBox(height: 22), checklist]);
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF047857), size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
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

class _FooterBand extends StatelessWidget {
  const _FooterBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            child: Row(
              children: const [
                _BrandMark(),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'NHIS brings identity, healthcare delivery, medical records, insurance workflows, analytics, and compliance into one secure national platform.',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(icon: Icons.add_circle_rounded, label: eyebrow),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 16,
            height: 1.52,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(360.0, MediaQuery.sizeOf(context).width - 40);

        return SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF047857), size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
