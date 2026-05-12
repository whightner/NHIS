import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../user/session_controller.dart';
import '../../user/user_service.dart';
import '../../user/user_session.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.session});

  final UserSession session;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _userService = UserService(baseUrl: UserService.defaultBaseUrl());

  Timer? _timer;
  DateTime _now = DateTime.now();
  bool? _apiConnected;
  bool? _jwtValid;
  bool _loggingOut = false;

  Duration get _sessionDuration {
    final duration = _now.difference(widget.session.createdAt.toLocal());
    return duration.isNegative ? Duration.zero : duration;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
      if (widget.session.isExpired(at: DateTime.now())) {
        _clearAndReturnToLogin();
      }
    });
    _validateStatus();
  }

  Future<void> _validateStatus() async {
    final apiFuture = _userService.ping();
    final jwtFuture = _userService.currentUser(
      accessToken: widget.session.accessToken,
    );

    final apiConnected = await apiFuture
        .then((_) => true)
        .catchError((_) => false);
    final jwtValid = await jwtFuture.then((_) => true).catchError((_) => false);

    if (!mounted) {
      return;
    }

    setState(() {
      _apiConnected = apiConnected;
      _jwtValid = jwtValid && !widget.session.isExpired();
    });
  }

  Future<void> _logout() async {
    if (_loggingOut) {
      return;
    }

    setState(() => _loggingOut = true);

    final refreshToken = widget.session.refreshToken;
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      try {
        await _userService.logout(refreshToken: refreshToken);
      } catch (_) {
        // Local session cleanup still matters if the API is unavailable.
      }
    }

    if (!mounted) {
      return;
    }

    _clearAndReturnToLogin();
  }

  void _clearAndReturnToLogin() {
    SessionController.instance.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;

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
            Text('NHIS Dashboard', style: AppTextStyles.h3),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _StatusChip(connected: _apiConnected),
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
            constraints: const BoxConstraints(maxWidth: 920),
            child: RefreshIndicator(
              onRefresh: _validateStatus,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Dashboard', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    widget.session.user.email ?? widget.session.user.fullName,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 2 : 1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: isWide ? 2.8 : 3.5,
                    children: [
                      _MetricTile(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.secondary,
                        label: 'Current Time',
                        value: _formatTime(_now),
                        detail: _formatDate(_now),
                      ),
                      _MetricTile(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.primary,
                        label: 'Session Duration',
                        value: _formatDuration(_sessionDuration),
                        detail: 'hh:mm:ss',
                      ),
                      _MetricTile(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor:
                            _apiConnected == true
                                ? AppColors.primary
                                : AppColors.danger,
                        label: 'API Status',
                        value: _statusText(
                          _apiConnected,
                          positive: 'Connected',
                          negative: 'Disconnected',
                        ),
                        detail:
                            _apiConnected == true
                                ? 'API is responding'
                                : 'Pull to retry',
                      ),
                      _MetricTile(
                        icon: Icons.verified_user_outlined,
                        iconColor:
                            _jwtValid == true
                                ? AppColors.primary
                                : AppColors.danger,
                        label: 'JWT Status',
                        value: _statusText(
                          _jwtValid,
                          positive: 'Valid',
                          negative: 'Invalid',
                        ),
                        detail:
                            _jwtValid == true
                                ? 'Token is valid'
                                : 'Session needs login',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _logout,
                    icon:
                        _loggingOut
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
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _userService.close();
    super.dispose();
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  static String _formatDate(DateTime value) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[value.weekday - 1]}, '
        '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  static String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String _statusText(
    bool? value, {
    required String positive,
    required String negative,
  }) {
    if (value == null) {
      return 'Checking';
    }

    return value ? positive : negative;
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.inkDarkest,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(detail, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected});

  final bool? connected;

  @override
  Widget build(BuildContext context) {
    final color =
        connected == null
            ? AppColors.warning
            : connected!
            ? AppColors.primary
            : AppColors.danger;
    final text =
        connected == null
            ? 'Checking'
            : connected!
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
