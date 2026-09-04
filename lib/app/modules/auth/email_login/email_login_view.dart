import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import 'email_login_controller.dart';

class EmailLoginView extends GetView<EmailLoginController> {
  const EmailLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EmailLoginController>()) {
      Get.put(EmailLoginController());
    }
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CfoAppBar(title: 'Sign in with email'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isRegisterMode.value) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'First name',
                          errorText: controller.fieldErrors['first_name'],
                          onChanged: (v) => controller.firstName.value = v,
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: _Field(
                          label: 'Last name',
                          onChanged: (v) => controller.lastName.value = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                _Field(
                  label: 'Email',
                  initialValue: 'priya.nair@example.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: controller.fieldErrors['email'],
                  onChanged: (v) => controller.email.value = v,
                ),
                const SizedBox(height: AppSpace.sm),
                _Field(
                  label: 'Password',
                  initialValue: 'password123',
                  obscureText: true,
                  errorText: controller.fieldErrors['password'],
                  onChanged: (v) => controller.password.value = v,
                ),
                if (controller.isRegisterMode.value) ...[
                  const SizedBox(height: AppSpace.sm),
                  _Field(
                    label: 'Confirm password',
                    obscureText: true,
                    onChanged: (v) => controller.passwordConfirmation.value = v,
                  ),
                ],
                const SizedBox(height: AppSpace.sm),
                PrimaryButton(
                  label: controller.isRegisterMode.value
                      ? 'Create account'
                      : 'Sign in',
                  loading: controller.loading.value,
                  onPressed: controller.submit,
                ),
                if (!controller.isRegisterMode.value)
                  Center(
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                      child: const Text('Forgot your password?'),
                    ),
                  ),
                if (controller.error.value.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.error.value,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.critical,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.sm),
                Center(
                  child: TextButton(
                    onPressed: controller.toggleMode,
                    child: Text(
                      controller.isRegisterMode.value
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.otp),
                    child: const Text('Use phone + OTP instead'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue ?? '');
    if ((widget.initialValue ?? '').isNotEmpty) {
      widget.onChanged(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(errorText: widget.errorText),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
