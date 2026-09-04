import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';

/// Drives the phone -> OTP -> verify flow. In debug builds the code the API
/// logs (`debug_code`) is prefilled automatically since there is no SMS
/// provider wired up yet.
class OtpController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final AuthService _auth = Get.find<AuthService>();

  final RxString phone = ''.obs;
  final RxString code = ''.obs;
  final RxString firstName = ''.obs;
  final RxBool codeSent = false.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxString debugCode = ''.obs;
  final RxInt resendIn = 0.obs;
  String? redirectRoute;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['redirect'] is String) redirectRoute = args['redirect'];
  }

  Future<void> requestOtp() async {
    if (phone.value.trim().length < 10) {
      error.value = 'Enter a valid 10-digit phone number.';
      return;
    }
    loading.value = true;
    error.value = '';
    try {
      final dc = await _repo.requestOtp(phone.value.trim());
      codeSent.value = true;
      if (kDebugMode && dc != null) {
        debugCode.value = dc;
        code.value = dc; // prefill so dev testing works end to end without SMS
      }
      _startResendTimer();
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
    } finally {
      loading.value = false;
    }
  }

  void _startResendTimer() {
    resendIn.value = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendIn.value > 0) resendIn.value--;
      return resendIn.value > 0;
    });
  }

  Future<void> verify() async {
    if (code.value.trim().length < 4) {
      error.value = 'Enter the code sent to your phone.';
      return;
    }
    loading.value = true;
    error.value = '';
    try {
      final result = await _repo.verifyOtp(
        phone: phone.value.trim(),
        code: code.value.trim(),
        deviceName: StorageService.instance.deviceName,
        firstName: firstName.value.trim().isEmpty ? null : firstName.value.trim(),
      );
      await _auth.completeLogin(token: result.token, customerModel: result.customer);
      if (redirectRoute != null) {
        Get.offAllNamed(AppRoutes.nav);
        Get.toNamed(redirectRoute!);
      } else {
        Get.offAllNamed(AppRoutes.nav);
      }
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
    } finally {
      loading.value = false;
    }
  }
}
