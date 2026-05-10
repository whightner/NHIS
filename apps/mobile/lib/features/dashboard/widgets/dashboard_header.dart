import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../user/user_model.dart';
import '../../../user/user_role.dart';

/// Dashboard greeting block with live date/time display and role badge.
class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key, required this.user});

  final UserModel user;

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ── Date / time helpers ────────────────────────────────────────────────────

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
    'Vendredi', 'Samedi', 'Dimanche',
  ];

  String get _date =>
      '${_days[_now.weekday - 1]} ${_now.day} ${_months[_now.month - 1]} ${_now.year}';

  String get _time =>
      '${_now.hour.toString().padLeft(2, '0')}:'
      '${_now.minute.toString().padLeft(2, '0')}:'
      '${_now.second.toString().padLeft(2, '0')}';

  String _greeting() {
    final h = _now.hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, ${widget.user.firstName} 👋',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 6),
              _RoleBadge(role: widget.user.role),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // ── Live clock ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _time,
                style: const TextStyle(
                  color: AppColors.inkDarkest,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _date,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Role badge ───────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  static String _label(UserRole r) => switch (r) {
    UserRole.admin               => 'Administrateur',
    UserRole.facilityAdmin       => 'Admin. Établissement',
    UserRole.doctor              => 'Médecin',
    UserRole.nurse               => 'Infirmier(ère)',
    UserRole.pharmacist          => 'Pharmacien(ne)',
    UserRole.laboratoryTechnician => 'Technicien Labo.',
    UserRole.registrationAgent   => "Agent d'enregistrement",
    UserRole.verifier            => 'Vérificateur',
    UserRole.auditor             => 'Auditeur',
    UserRole.insuranceOfficer    => 'Agent Assurance',
    UserRole.patient             => 'Patient',
    UserRole.supportAgent        => 'Support',
    UserRole.publicHealthOfficer => 'Officier Santé Pub.',
    UserRole.dataAnalyst         => 'Analyste de données',
  };

  static Color _color(UserRole r) {
    if (r == UserRole.doctor || r == UserRole.nurse ||
        r == UserRole.pharmacist || r == UserRole.laboratoryTechnician) {
      return AppColors.primary;
    }
    if (r == UserRole.admin || r == UserRole.facilityAdmin ||
        r == UserRole.registrationAgent || r == UserRole.verifier) {
      return AppColors.secondary;
    }
    if (r == UserRole.patient) return AppColors.pink;
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_outline_rounded, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            _label(role),
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
