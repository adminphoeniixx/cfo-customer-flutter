import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import 'otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OtpController>()) Get.put(OtpController());
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(CfoAppBar.barHeight),
        child: Obx(
          () => CfoAppBar(
            title: controller.codeSent.value ? 'Enter the code' : 'Sign in',
            showBack: controller.codeSent.value || Navigator.of(context).canPop(),
            onBack: controller.codeSent.value
                ? () => controller.codeSent.value = false
                : null,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpace.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 220,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!controller.codeSent.value) ...[
                          const AppLogo(size: 72),
                          const SizedBox(height: AppSpace.sm),
                          Text('CFO Shop', style: AppTextStyles.h2),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            'Handloom, home and more — from sellers you can name',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.ink3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpace.xl),
                        ],
                        if (!controller.codeSent.value)
                          ..._phoneStep()
                        else
                          ..._codeStep(),
                        if (controller.error.value.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            controller.error.value,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.critical,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppSpace.sm),
                        PrimaryButton(
                          label: controller.codeSent.value
                              ? 'Verify & continue'
                              : 'Continue',
                          loading: controller.loading.value,
                          onPressed: controller.codeSent.value
                              ? controller.verify
                              : controller.requestOtp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!controller.codeSent.value)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.md,
                    0,
                    AppSpace.md,
                    AppSpace.md,
                  ),
                  child: Text(
                    'New to CFO Shop? Entering your number creates your account.\nBy continuing you accept the terms and privacy policy.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(height: 1.45),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _phoneStep() => [
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Mobile number',
        style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    const SizedBox(height: 6),
    TextField(
      keyboardType: TextInputType.phone,
      maxLength: 10,
      controller:
          TextEditingController(text: Get.find<OtpController>().phone.value)
            ..selection = TextSelection.collapsed(
              offset: Get.find<OtpController>().phone.value.length,
            ),
      decoration: const InputDecoration(
        hintText: '98765 43210',
        counterText: '',
      ),
      onChanged: (v) => Get.find<OtpController>().phone.value = v,
    ),
  ];

  List<Widget> _codeStep() => [
    TextField(
      keyboardType: TextInputType.number,
      maxLength: 6,
      controller:
          TextEditingController(text: Get.find<OtpController>().code.value)
            ..selection = TextSelection.collapsed(
              offset: Get.find<OtpController>().code.value.length,
            ),
      decoration: const InputDecoration(
        hintText: '6-digit code',
        counterText: '',
      ),
      onChanged: (v) => Get.find<OtpController>().code.value = v,
      style: AppTextStyles.h2.copyWith(letterSpacing: 8),
    ),
    if (kDebugMode && Get.find<OtpController>().debugCode.value.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'Dev only — no SMS provider yet: code is ${Get.find<OtpController>().debugCode.value}',
          style: AppTextStyles.tiny.copyWith(color: AppColors.sale),
        ),
      ),
    const SizedBox(height: AppSpace.sm),
    TextField(
      decoration: const InputDecoration(
        hintText: 'Your first name (new accounts)',
      ),
      onChanged: (v) => Get.find<OtpController>().firstName.value = v,
    ),
    const SizedBox(height: AppSpace.sm),
    Obx(() {
      final c = Get.find<OtpController>();
      return TextButton(
        onPressed: c.resendIn.value == 0 ? c.requestOtp : null,
        child: Text(
          c.resendIn.value == 0
              ? 'Resend code'
              : 'Resend in ${c.resendIn.value}s',
        ),
      );
    }),
  ];
}
