import 'package:flutter/material.dart';
import '../registration_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Dispatcher: renders the correct role-specific form based on [state.role].
class StepRoleSpecific extends StatelessWidget {
  const StepRoleSpecific({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    switch (state.role) {
      case 'patient':
        return _PatientForm(state: state, onNext: onNext, onBack: onBack);
      case 'doctor':
        return _DoctorForm(state: state, onNext: onNext, onBack: onBack);
      case 'admin':
        return _AdminForm(state: state, onNext: onNext, onBack: onBack);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Patient ────────────────────────────────────────────────────────────────

class _PatientForm extends StatelessWidget {
  const _PatientForm({
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Patient Information', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          'Your basic profile is sufficient to create a patient account.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
        ),
        const SizedBox(height: 24),
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          color: AppColors.secondary,
          message:
              'As a patient, your identity and contact details already capture everything needed. No additional information is required.',
        ),
        const SizedBox(height: 28),
        _NavButtons(onBack: onBack, onNext: onNext, nextLabel: 'Review'),
      ],
    );
  }
}

// ── Doctor ─────────────────────────────────────────────────────────────────

class _DoctorForm extends StatefulWidget {
  const _DoctorForm({
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<_DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<_DoctorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _license;
  late final TextEditingController _issuer;
  late final TextEditingController _specialty;
  late final TextEditingController _inviteCode;

  @override
  void initState() {
    super.initState();
    _license = TextEditingController(text: widget.state.licenseNumber);
    _issuer = TextEditingController(text: widget.state.licenseIssuer);
    _specialty = TextEditingController(text: widget.state.specialty);
    _inviteCode = TextEditingController(text: widget.state.inviteCode);
  }

  @override
  void dispose() {
    _license.dispose();
    _issuer.dispose();
    _specialty.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.state
      ..licenseNumber = _license.text.trim()
      ..licenseIssuer = _issuer.text.trim()
      ..specialty = _specialty.text.trim()
      ..inviteCode = _inviteCode.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Professional Details', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Provide your medical license and professional information.',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _license,
            textInputAction: TextInputAction.next,
            decoration: _dec('License number *', Icons.badge_outlined),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'License number is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _issuer,
            textInputAction: TextInputAction.next,
            decoration: _dec(
              'Issuing authority (optional)',
              Icons.account_balance_outlined,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _specialty,
            textInputAction: TextInputAction.next,
            decoration: _dec('Specialty / Department (optional)', Icons.work_outline_rounded),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _inviteCode,
            textInputAction: TextInputAction.done,
            obscureText: true,
            onFieldSubmitted: (_) => _submit(),
            decoration: _dec('Doctor invite code *', Icons.key_outlined),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Invite code is required for doctor registration' : null,
          ),
          const SizedBox(height: 8),
          Text(
            'The invite code is provided by your system administrator.',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkLight),
          ),
          const SizedBox(height: 28),
          _NavButtons(onBack: widget.onBack, onNext: _submit, nextLabel: 'Review'),
        ],
      ),
    );
  }

  static InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ── Admin ──────────────────────────────────────────────────────────────────

class _AdminForm extends StatefulWidget {
  const _AdminForm({
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<_AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<_AdminForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _inviteCode;

  @override
  void initState() {
    super.initState();
    _inviteCode = TextEditingController(text: widget.state.inviteCode);
  }

  @override
  void dispose() {
    _inviteCode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.state.inviteCode = _inviteCode.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Administrator Access', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Administrator accounts require a secure authorisation code.',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
          ),
          const SizedBox(height: 24),
          _InfoBanner(
            icon: Icons.security_outlined,
            color: AppColors.warning,
            message:
                'Administrator access is restricted. You must provide the admin invite code issued by your organisation.',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _inviteCode,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Admin invite code *',
              prefixIcon: const Icon(Icons.key_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Admin invite code is required' : null,
          ),
          const SizedBox(height: 28),
          _NavButtons(onBack: widget.onBack, onNext: _submit, nextLabel: 'Review'),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
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
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
