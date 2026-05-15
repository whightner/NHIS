import 'package:flutter/material.dart';
import '../registration_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class StepAccountSecurity extends StatefulWidget {
  const StepAccountSecurity({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  final RegistrationState state;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<StepAccountSecurity> createState() => _StepAccountSecurityState();
}

class _StepAccountSecurityState extends State<StepAccountSecurity> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _password;
  late final TextEditingController _confirm;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController(text: widget.state.password);
    _confirm = TextEditingController(text: widget.state.confirmPassword);
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.state
      ..password = _password.text
      ..confirmPassword = _confirm.text;
    widget.onNext();
  }

  String? _validatePassword(String? value) {
    final pw = value ?? '';
    if (pw.isEmpty) return 'Password is required';
    if (pw.length < 8) return 'At least 8 characters';
    if (!pw.contains(RegExp(r'[A-Z]'))) return 'Add an uppercase letter';
    if (!pw.contains(RegExp(r'[a-z]'))) return 'Add a lowercase letter';
    if (!pw.contains(RegExp(r'[0-9]'))) return 'Add a number';
    if (!pw.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|`~]'))) {
      return 'Add a special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Password', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Choose a strong password to protect your account.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _password,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: _dec(
              'Password',
              Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: _visibilityToggle(
                visible: !_obscurePassword,
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 8),
          _PasswordRequirements(password: _password),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirm,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _dec(
              'Confirm password',
              Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: _visibilityToggle(
                visible: !_obscureConfirm,
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v != _password.text) return 'Passwords do not match';
              return null;
            },
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
                  onPressed: _submit,
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
      ),
    );
  }

  static Widget _visibilityToggle({
    required bool visible,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
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

class _PasswordRequirements extends StatefulWidget {
  const _PasswordRequirements({required this.password});
  final TextEditingController password;

  @override
  State<_PasswordRequirements> createState() => _PasswordRequirementsState();
}

class _PasswordRequirementsState extends State<_PasswordRequirements> {
  @override
  void initState() {
    super.initState();
    widget.password.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final pw = widget.password.text;
    return Column(
      children: [
        _req('At least 8 characters', pw.length >= 8),
        _req('Uppercase letter (A–Z)', pw.contains(RegExp(r'[A-Z]'))),
        _req('Lowercase letter (a–z)', pw.contains(RegExp(r'[a-z]'))),
        _req('Number (0–9)', pw.contains(RegExp(r'[0-9]'))),
        _req(
          'Special character (!@#\$…)',
          pw.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|`~]')),
        ),
      ],
    );
  }

  static Widget _req(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: met ? AppColors.primary : AppColors.inkLight,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? AppColors.primary : AppColors.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}
