import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _repo = Get.find<AccountRepository>();
  final _auth = Get.find<AuthService>();
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController dateOfBirth;
  String? gender;
  bool acceptsMarketing = false;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final c = _auth.customer.value;
    firstName = TextEditingController(text: c?.firstName ?? '');
    lastName = TextEditingController(text: c?.lastName ?? '');
    email = TextEditingController(text: c?.email ?? '');
    phone = TextEditingController(text: c?.phone ?? '');
    dateOfBirth = TextEditingController(text: c?.dateOfBirth ?? '');
    gender = c?.gender ?? 'female';
    acceptsMarketing = c?.acceptsMarketing ?? false;
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    dateOfBirth.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final updated = await _repo.updateMe({
        'first_name': firstName.text.trim(),
        'last_name': lastName.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'date_of_birth': dateOfBirth.text.trim(),
        if (gender != null) 'gender': gender,
        'accepts_marketing': acceptsMarketing,
      });
      _auth.customer.value = updated;
      Get.back();
      CfoToast.success('Saved');
    } on AppException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This will delete your customer account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteMe();
      await _auth.logout();
      CfoToast.success('Account deleted');
      Get.offAllNamed(AppRoutes.nav);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _auth.customer.value;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CfoAppBar.editForm(
        title: 'Your details',
        onSave: _save,
        saving: saving,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Row(
            children: [
              Expanded(
                child: _Field(label: 'First name', controller: firstName),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(label: 'Last name', controller: lastName),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _Field(
            label: 'Email',
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 5),
          Text(
            c?.emailVerified == true ? '✓ Verified' : 'Not verified yet',
            style: AppTextStyles.caption.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 11),
          _Field(
            label: 'Mobile number',
            controller: phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 11),
          _Field(label: 'Date of birth', controller: dateOfBirth),
          const SizedBox(height: 11),
          _GenderField(
            value: gender,
            onChanged: (v) => setState(() => gender = v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Offers and new arrivals by email',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order updates are sent either way.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              _Switch(
                value: acceptsMarketing,
                onTap: () =>
                    setState(() => acceptsMarketing = !acceptsMarketing),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.critical),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).size.height * 0.30),
          _DangerButton(
            label: 'Delete my account',
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.body.copyWith(fontSize: 14),
            decoration: _inputDecoration(),
          ),
        ),
      ],
    );
  }
}

class _GenderField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 34,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            style: AppTextStyles.body.copyWith(fontSize: 14),
            decoration: _inputDecoration().copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'female', child: Text('female')),
              DropdownMenuItem(value: 'male', child: Text('male')),
              DropdownMenuItem(
                value: 'prefer not to say',
                child: Text('prefer not to say'),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _Switch({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.deal : AppColors.line,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.critical,
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 14,
            height: 1,
            letterSpacing: 0.02,
          ),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label),
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.action),
    ),
  );
}
