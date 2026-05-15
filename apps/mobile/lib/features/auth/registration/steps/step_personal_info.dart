import 'package:flutter/material.dart';
import '../registration_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class StepPersonalInfo extends StatefulWidget {
  const StepPersonalInfo({
    super.key,
    required this.state,
    required this.onNext,
  });

  final RegistrationState state;
  final VoidCallback onNext;

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _dob;
  String _sex = '';

  static const _sexOptions = [
    ('Male', 'male'),
    ('Female', 'female'),
    ('Other', 'other'),
    ('Prefer not to say', 'prefer_not_to_say'),
  ];

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.state.firstName);
    _lastName = TextEditingController(text: widget.state.lastName);
    _dob = TextEditingController(text: widget.state.dateOfBirth);
    _sex = widget.state.sex;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _dob.text.isNotEmpty
        ? DateTime.tryParse(_dob.text) ?? DateTime(1990)
        : DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      setState(() => _dob.text = formatted);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_sex.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your sex.')),
      );
      return;
    }
    widget.state
      ..firstName = _firstName.text.trim()
      ..lastName = _lastName.text.trim()
      ..dateOfBirth = _dob.text.trim()
      ..sex = _sex;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Personal Information', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Tell us a little about yourself.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkLight),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _dec('First name', Icons.person_outline_rounded),
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _dec('Last name', Icons.person_outline_rounded),
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _dob,
            readOnly: true,
            onTap: _pickDate,
            decoration: _dec(
              'Date of birth (YYYY-MM-DD)',
              Icons.calendar_today_outlined,
            ).copyWith(
              suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
            ),
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Date of birth is required'
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Sex',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sexOptions.map((opt) {
              final selected = _sex == opt.$2;
              return ChoiceChip(
                label: Text(opt.$1),
                selected: selected,
                onSelected: (_) => setState(() => _sex = opt.$2),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.inkMedium,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
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
