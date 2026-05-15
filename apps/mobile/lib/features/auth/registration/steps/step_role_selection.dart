import 'package:flutter/material.dart';
import '../registration_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class StepRoleSelection extends StatefulWidget {
  const StepRoleSelection({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<StepRoleSelection> createState() => _StepRoleSelectionState();
}

class _StepRoleSelectionState extends State<StepRoleSelection> {
  String _role = '';

  @override
  void initState() {
    super.initState();
    _role = widget.state.role;
  }

  void _submit() {
    if (_role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role to continue.')),
      );
      return;
    }
    widget.state.role = _role;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Choose Your Role', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          'Select the option that best describes you.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
        ),
        const SizedBox(height: 24),
        _RoleTile(
          value: 'patient',
          selected: _role == 'patient',
          icon: Icons.person_outline_rounded,
          title: 'Patient / Student',
          subtitle: 'Manage your health records and appointments.',
          onTap: () => setState(() => _role = 'patient'),
        ),
        const SizedBox(height: 12),
        _RoleTile(
          value: 'doctor',
          selected: _role == 'doctor',
          icon: Icons.medical_services_outlined,
          title: 'Doctor / Staff',
          subtitle: 'Access patient records and clinical tools.',
          onTap: () => setState(() => _role = 'doctor'),
        ),
        const SizedBox(height: 12),
        _RoleTile(
          value: 'admin',
          selected: _role == 'admin',
          icon: Icons.admin_panel_settings_outlined,
          title: 'Administrator',
          subtitle: 'Manage platform configuration and users.',
          onTap: () => setState(() => _role = 'admin'),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _role.isEmpty ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.value,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String value;
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withAlpha(28)
                    : AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.inkLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.primaryDeep
                          : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: selected
                          ? AppColors.primaryMid
                          : AppColors.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
