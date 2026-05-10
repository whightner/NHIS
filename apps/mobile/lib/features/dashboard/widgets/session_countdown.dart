import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// Compte à rebours de session.
///
/// Reads [expiresAt] every second and displays remaining time as MM:SS.
/// Colour transitions: green → orange (< 10 min) → red (< 5 min).
/// Calls [onExpired] when the timer reaches zero.
class SessionCountdown extends StatefulWidget {
  const SessionCountdown({
    super.key,
    required this.expiresAt,
    required this.totalDuration,
    required this.onExpired,
    this.onExtend,
  });

  /// When the current session expires.
  final DateTime expiresAt;

  /// Total session length used to draw the circular progress ring.
  final Duration totalDuration;

  /// Called when remaining time reaches zero.
  final VoidCallback onExpired;

  /// Optional callback for an "Extend session" action.
  final VoidCallback? onExtend;

  @override
  State<SessionCountdown> createState() => _SessionCountdownState();
}

class _SessionCountdownState extends State<SessionCountdown> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _refresh();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  void _refresh() {
    final diff = widget.expiresAt.difference(DateTime.now());
    if (!mounted) return;
    if (diff.isNegative || diff == Duration.zero) {
      _ticker?.cancel();
      widget.onExpired();
      return;
    }
    setState(() => _remaining = diff);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Derived values ─────────────────────────────────────────────────────────

  Color get _color {
    final mins = _remaining.inMinutes;
    if (mins >= 10) return AppColors.primary;
    if (mins >= 5)  return AppColors.warning;
    return AppColors.danger;
  }

  double get _progress {
    final total = widget.totalDuration.inSeconds;
    if (total == 0) return 0;
    return (_remaining.inSeconds / total).clamp(0.0, 1.0);
  }

  String get _mm =>
      _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  String get _ss =>
      _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isUrgent = _remaining.inMinutes < 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: color.withAlpha(isUrgent ? 22 : 14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(isUrgent ? 80 : 50)),
      ),
      child: Row(
        children: [
          // ── Circular ring countdown ────────────────────────────────────────
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 5.5,
                    backgroundColor: color.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _mm,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      ':$_ss',
                      style: TextStyle(
                        color: color.withAlpha(180),
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // ── Text info ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session expire dans',
                  style: TextStyle(
                    color: color.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_mm min $_ss sec',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isUrgent) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Votre session va bientôt expirer.',
                    style: TextStyle(
                      color: color.withAlpha(160),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Extend button (visible only when urgent) ───────────────────────
          if (isUrgent && widget.onExtend != null) ...[
            const SizedBox(width: 12),
            FilledButton(
              onPressed: widget.onExtend,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Prolonger',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
