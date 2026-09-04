import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _repo = AuthRepository();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.forgotPassword(_email.text.trim());
      setState(() => _sent = true);
      CfoToast.success('Reset link sent');
    } on AppException catch (e) {
      setState(() => _error = e.message);
      CfoToast.error(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: CfoAppBar(title: 'Reset password'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: _sent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mark_email_read_outlined, color: AppColors.brand, size: 40),
                  const SizedBox(height: AppSpace.md),
                  Text('Check your email', style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  const Text('If an account exists for that address, we sent a reset link.', style: AppTextStyles.body),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forgot your password?', style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  const Text('Enter your email and we will send you a reset link.', style: AppTextStyles.body),
                  const SizedBox(height: AppSpace.lg),
                  TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email address')),
                  if (_error != null) ...[
                    const SizedBox(height: 6),
                    Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.critical)),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  PrimaryButton(label: 'Send reset link', loading: _loading, onPressed: _submit),
                ],
              ),
      ),
    );
  }
}
