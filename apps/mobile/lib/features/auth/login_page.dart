import 'package:flutter/material.dart';
import '../../app/router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../shared/widgets/nhis_button.dart';
import '../../user/user_model.dart';
import '../../user/user_role.dart';
import '../../user/user_session.dart';
import '../../user/user_status.dart';

/// Staff / admin login screen.
/// On success → navigates to [DashboardPage] with a [UserSession].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey   = GlobalKey<FormState>();
  final _idCtrl    = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _error = null; });

    // Simulate network round-trip (replace with real API call).
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    // ── Mock session ──────────────────────────────────────────────────────────
    // TODO: replace with real auth service response.
    final session = UserSession(
      user: UserModel(
        id: 'USR-001',
        firstName: 'Kofi',
        lastName: 'Agyeman',
        role: UserRole.doctor,
        status: UserStatus.active,
        email: _idCtrl.text.trim(),
      ),
      accessToken: 'mock-access-token-xxxxx',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      createdAt: DateTime.now(),
    );
    // ─────────────────────────────────────────────────────────────────────────

    setState(() => _loading = false);

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
      arguments: session,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  _LoginHeader(isWide: isWide),
                  const SizedBox(height: 28),
                  _LoginCard(
                    formKey: _formKey,
                    idCtrl: _idCtrl,
                    passCtrl: _passCtrl,
                    obscure: _obscure,
                    loading: _loading,
                    error: _error,
                    onToggleObscure: () =>
                        setState(() => _obscure = !_obscure),
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 24),
                  const _LoginFooter(),
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
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrandMark(size: 60),
        const SizedBox(height: 16),
        const Text('NHIS', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text(
          'Secure staff access portal',
          style: AppTextStyles.body.copyWith(color: AppColors.inkLight),
        ),
      ],
    );
  }
}

// ── Card ────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.idCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController idCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sign in', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              'Enter your staff credentials to access the platform.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
            ),
            const SizedBox(height: 24),

            // Staff ID / email
            _FieldLabel(label: 'Staff ID or email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: idCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _inputDecoration(
                hint: 'e.g. K.AGYEMAN or kofi@nhis.cm',
                icon: Icons.badge_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Staff ID or email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password
            _FieldLabel(label: 'Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: passCtrl,
              obscureText: obscure,
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.inkLight,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryMid,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  'Forgot credentials?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Error banner
            if (error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(error!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            NhisFilledButton(
              label: 'Sign in',
              onPressed: onSubmit,
              icon: Icons.login_rounded,
              loading: loading,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.inkLight, size: 20),
      hintStyle: const TextStyle(
        color: AppColors.inkLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }
}

// ── Footer ──────────────────────────────────────────────────────────────────

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_outlined,
            size: 14, color: AppColors.inkLight),
        const SizedBox(width: 6),
        Text(
          'Secure · Encrypted · Audited',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkLight),
        ),
      ],
    );
  }
}

// ── Shared field label ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.inkDarkest,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
