import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../user/session_controller.dart';
import '../../user/user_service.dart';
import '../../user/user_session.dart';

/// Minimal post-login dashboard — shows only what the spec requires:
/// email · login time · session duration · active session state · logout.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.session});

  final UserSession session;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _userService = UserService(baseUrl: UserService.defaultBaseUrl());

  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _loggingOut = false;
  bool? _sessionActive;

  Duration get _sessionDuration {
    final d = _now.difference(widget.session.createdAt.toLocal());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() => _now = now);
      if (widget.session.isExpired(at: now)) {
        _clearAndGoHome();
      }
    });
    _verifySessionActive();
  }

  Future<void> _verifySessionActive() async {
    final valid = await _userService
        .currentUser(accessToken: widget.session.accessToken)
        .then((_) => true)
        .catchError((_) => false);

    if (!mounted) return;
    setState(() => _sessionActive = valid && !widget.session.isExpired());
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    final token = widget.session.refreshToken;
    if (token != null && token.trim().isNotEmpty) {
      try {
        await _userService.logout(refreshToken: token);
      } catch (_) {
        // Proceed with local cleanup even if the API is unreachable.
      }
    }

    if (!mounted) return;
    _clearAndGoHome();
  }

  void _clearAndGoHome() {
    SessionController.instance.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;
    final loginTime = widget.session.createdAt.toLocal();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            BrandMark(size: 34),
            SizedBox(width: 10),
            Text('NHIS', style: AppTextStyles.h3),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _SessionChip(active: _sessionActive),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Welcome banner
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: AppColors.primaryDeep,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'You have successfully logged in.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Session info card
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: user.email ?? user.fullName,
                      ),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.login_rounded,
                        label: 'Login Time',
                        value: _formatDateTime(loginTime),
                      ),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.timer_outlined,
                        label: 'Session Time',
                        value: _formatDuration(_sessionDuration),
                        valueMonospace: true,
                      ),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Session State',
                        valueWidget: _SessionStateBadge(active: _sessionActive),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout
                OutlinedButton.icon(
                  onPressed: _loggingOut ? null : _logout,
                  icon: _loggingOut
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size.fromHeight(48),
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

  @override
  void dispose() {
    _ticker?.cancel();
    _userService.close();
    super.dispose();
  }

  static String _formatDateTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    final s = value.second.toString().padLeft(2, '0');
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}  $h:$m:$s';
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueMonospace = false,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool valueMonospace;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkLight),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkLight),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '',
                  style: TextStyle(
                    color: AppColors.inkDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: valueMonospace ? 'monospace' : null,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border, indent: 18);
  }
}

class _SessionStateBadge extends StatelessWidget {
  const _SessionStateBadge({required this.active});
  final bool? active;

  @override
  Widget build(BuildContext context) {
    if (active == null) {
      return _badge(AppColors.warning, Icons.hourglass_top_rounded, 'Checking');
    }
    return active!
        ? _badge(AppColors.primary, Icons.check_circle_rounded, 'Active')
        : _badge(AppColors.danger, Icons.cancel_rounded, 'Expired');
  }

  static Widget _badge(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({required this.active});
  final bool? active;

  @override
  Widget build(BuildContext context) {
    final color = active == null
        ? AppColors.warning
        : active!
        ? AppColors.primary
        : AppColors.danger;
    final text = active == null
        ? 'Checking'
        : active!
        ? 'Connected'
        : 'Disconnected';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}