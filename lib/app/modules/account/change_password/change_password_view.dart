import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _repo = Get.find<AccountRepository>();
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool saving = false;
  String? error;

  Future<void> _submit() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await _repo.changePassword(
        currentPassword: current.text.isEmpty ? null : current.text,
        password: next.text,
        passwordConfirmation: confirm.text,
      );
      Get.back();
      CfoToast.success('Password changed. Other devices were signed out.');
    } on AppException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Change password'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.md),
        children: [
          const Text('Changing your password signs every other device out.'),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: current,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Current password (if set)',
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: next,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'New password'),
          ),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Confirm new password'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: AppSpace.lg),
          PrimaryButton(
            label: 'Update password',
            loading: saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
