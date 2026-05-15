import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../user/user_service.dart';
import 'registration_state.dart';
import 'steps/step_personal_info.dart';
import 'steps/step_contact_info.dart';
import 'steps/step_account_security.dart';
import 'steps/step_role_selection.dart';
import 'steps/step_role_specific.dart';
import 'steps/step_review_confirm.dart';

/// Six-step registration wizard.
/// All state is held here; steps are pure UI with callbacks.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _state = RegistrationState();
  final _userService = UserService(baseUrl: UserService.defaultBaseUrl());
  final _pageController = PageController();

  static const _totalSteps = 6;
  int _currentStep = 0;
  bool _loading = false;
  String? _submitError;

  @override
  void dispose() {
    _pageController.dispose();
    _userService.close();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────

  void _goTo(int step) {
    setState(() {
      _currentStep = step;
      _submitError = null;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goTo(_currentStep + 1);
  void _back() => _goTo(_currentStep - 1);

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _submitError = null;
    });

    try {
      await _userService.register(request: _state.toJson());

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.registrationSuccess);
    } on UserServiceException catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = 'Unable to reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          const BrandMark(size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NHIS', style: AppTextStyles.h2),
                                Text(
                                  'Create an account',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.inkLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Step counter
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Step ${_currentStep + 1} of $_totalSteps',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / _totalSteps,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Steps (PageView so the content animates horizontally)
                      SizedBox(
                        height: _stepHeight(),
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StepPersonalInfo(
                              state: _state,
                              onNext: _next,
                            ),
                            StepContactInfo(
                              state: _state,
                              onNext: _next,
                              onBack: _back,
                            ),
                            StepAccountSecurity(
                              state: _state,
                              onNext: _next,
                              onBack: _back,
                            ),
                            StepRoleSelection(
                              state: _state,
                              onNext: _next,
                              onBack: _back,
                            ),
                            StepRoleSpecific(
                              state: _state,
                              onNext: _next,
                              onBack: _back,
                            ),
                            StepReviewConfirm(
                              state: _state,
                              onSubmit: _submit,
                              onBack: _back,
                              loading: _loading,
                              error: _submitError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Footer — link back to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.inkLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            child: Text(
                              'Login',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Rough step height to avoid overflow — all steps have bounded content.
  double _stepHeight() {
    switch (_currentStep) {
      case 0: return 480; // personal info (date picker + sex chips)
      case 2: return 460; // password + requirements list
      case 4: return _state.isDoctor ? 520 : (_state.isAdmin ? 360 : 260);
      case 5: return _submitError != null ? 600 : 540;
      default: return 340;
    }
  }
}
