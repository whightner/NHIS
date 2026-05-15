import 'package:flutter/material.dart';
import '../registration_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class StepReviewConfirm extends StatelessWidget {
  const StepReviewConfirm({
    super.key,
    required this.state,
    required this.onSubmit,
    required this.onBack,
    required this.loading,
    this.error,
  });

  final RegistrationState state;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Review & Confirm', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          'Please review your information before submitting.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Personal Information',
          rows: [
            ('Full name', state.fullName),
            ('Date of birth', state.dateOfBirth),
            ('Sex', state.sex),
          ],
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Contact Information',
          rows: [
            ('Email', state.email),
            if (state.phoneNumber.trim().isNotEmpty)
              ('Phone', state.phoneNumber),
          ],
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Role',
          rows: [
            ('Account type', _roleLabel(state.role)),
          ],
        ),
        if (state.isDoctor) ...[
          const SizedBox(height: 12),
          _Section(
            title: 'Professional Details',
            rows: [
              ('License number', state.licenseNumber),
              if (state.licenseIssuer.trim().isNotEmpty)
                ('Issuer', state.licenseIssuer),
              if (state.specialty.trim().isNotEmpty)
                ('Specialty', state.specialty),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.check_box_outlined, size: 18, color: AppColors.inkLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: error!),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: loading ? null : onBack,
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
                onPressed: loading ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'patient':
        return 'Patient / Student';
      case 'doctor':
        return 'Doctor / Staff';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.inkMedium,
              ),
            ),
            const SizedBox(height: 10),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.$1,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkLight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(18),
        border: Border.all(color: AppColors.danger.withAlpha(70)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
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
