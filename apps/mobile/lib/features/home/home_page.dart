import 'package:flutter/material.dart';
import '../../app/router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/section_shell.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/impact_strip.dart';
import 'widgets/health_booklet_section.dart';
import 'widgets/network_section.dart';
import 'widgets/capability_section.dart';
import 'widgets/security_section.dart';
import 'widgets/footer_band.dart';

/// Public-facing landing page. No logic — just assembles section widgets.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                SliverToBoxAdapter(
                  child: HomeHeader(
                    isWide: isWide,
                    onLoginTap: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                  ),
                ),
                SliverToBoxAdapter(child: HeroSection(isWide: isWide)),
                const SliverToBoxAdapter(child: ImpactStrip()),
                SliverToBoxAdapter(
                  child: SectionShell(
                    child: HealthBookletSection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionShell(
                    backgroundColor: AppColors.backgroundBlue,
                    child: NetworkSection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionShell(
                    child: CapabilitySection(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionShell(
                    backgroundColor: AppColors.backgroundGreen,
                    child: SecuritySection(isWide: isWide),
                  ),
                ),
                const SliverToBoxAdapter(child: FooterBand()),
              ],
            );
          },
        ),
      ),
    );
  }
}
