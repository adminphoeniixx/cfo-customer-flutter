import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';

class EmailLoginController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final AuthService _auth = Get.find<AuthService>();

  final RxBool isRegisterMode = false.obs;
  final RxBool loading = true.obs..value = false;
  final RxString error = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final email = ''.obs;
  final password = ''.obs;
  final passwordConfirmation = ''.obs;
  final firstName = ''.obs;
  final lastName = ''.obs;

  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;
    error.value = '';
    fieldErrors.clear();
  }

  Future<void> submit() async {
    loading.value = true;
    error.value = '';
    fieldErrors.clear();
    try {
      final result = isRegisterMode.value
          ? await _repo.register(
              firstName: firstName.value.trim(),
              lastName: lastName.value.trim(),
              email: email.value.trim(),
              password: password.value,
              passwordConfirmation: passwordConfirmation.value,
              deviceName: StorageService.instance.deviceName,
            )
          : await _repo.login(
              email: email.value.trim(),
              password: password.value,
              deviceName: StorageService.instance.deviceName,
            );
      await _auth.completeLogin(token: result.token, customerModel: result.customer);
      Get.offAllNamed(AppRoutes.nav);
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
      if (e.fieldErrors != null) {
        fieldErrors.assignAll(e.fieldErrors!.map((k, v) => MapEntry(k, v.first)));
      }
    } finally {
      loading.value = false;
    }
  }
}
