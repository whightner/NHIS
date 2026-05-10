import 'package:flutter/material.dart';
import '../../app/router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../user/user_session.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/session_countdown.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_activity_list.dart';

/// Authenticated home — shown after a successful login.
///
/// Receives a [UserSession] from [LoginPage] via the navigator arguments.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.session});

  final UserSession session;

  // ── Logout ─────────────────────────────────────────────────────────────────

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  // ── Session expired ────────────────────────────────────────────────────────

  void _onSessionExpired(BuildContext context) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.timer_off_rounded,
          color: AppColors.danger,
          size: 36,
        ),
        title: const Text('Session expirée'),
        content: const Text(
          'Votre session a expiré pour des raisons de sécurité. '
          'Veuillez vous reconnecter.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Se reconnecter'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DashboardAppBar(
        onLogout: () => _logout(context),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting + live clock ────────────────────────────────
                  DashboardHeader(user: session.user),
                  const SizedBox(height: 20),

                  // ── Compte à rebours de session ──────────────────────────
                  SessionCountdown(
                    expiresAt: session.expiresAt,
                    totalDuration: const Duration(minutes: 30),
                    onExpired: () => _onSessionExpired(context),
                    onExtend: () {
                      // TODO: call refresh-token endpoint.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session prolongée de 30 minutes.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Quick stats ──────────────────────────────────────────
                  _SectionLabel(label: 'Aperçu', icon: Icons.bar_chart_rounded),
                  const SizedBox(height: 12),
                  const QuickStatsRow(),
                  const SizedBox(height: 24),

                  // ── Quick actions ────────────────────────────────────────
                  _SectionLabel(
                    label: 'Actions rapides',
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 12),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),

                  // ── Recent activity ──────────────────────────────────────
                  _SectionLabel(
                    label: 'Activité récente',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 12),
                  const RecentActivityList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AppBar ───────────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _DashboardAppBar({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: const Row(
        children: [
          BrandMark(size: 36),
          SizedBox(width: 10),
          Text(
            'NHIS Dashboard',
            style: TextStyle(
              color: AppColors.inkDarkest,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
      actions: [
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          color: AppColors.inkMuted,
          tooltip: 'Se déconnecter',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.inkMuted),
        const SizedBox(width: 7),
        Text(label, style: AppTextStyles.labelLarge),
      ],
    );
  }
}
