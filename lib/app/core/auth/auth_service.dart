import 'package:get/get.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/auth_repository.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';

/// App-wide auth state. Put once at startup, read anywhere with
/// `Get.find<AuthService>()`.
class AuthService extends GetxService {
  final Rxn<Customer> customer = Rxn<Customer>();
  final RxBool isLoggedIn = false.obs;
  final RxBool bootstrapping = true.obs;

  final AuthRepository _authRepo = AuthRepository();

  Future<AuthService> init() async {
    final api = Get.find<ApiClient>();
    api.onUnauthorized = forceLogout;

    final token = await StorageService.instance.readToken();
    isLoggedIn.value = token != null && token.isNotEmpty;
    bootstrapping.value = false;
    return this;
  }

  Future<void> completeLogin({required String token, required Customer customerModel}) async {
    await StorageService.instance.saveToken(token);
    customer.value = customerModel;
    isLoggedIn.value = true;
  }

  Future<void> logout({bool remote = true}) async {
    if (remote) {
      try {
        await _authRepo.logout();
      } catch (_) {
        // best-effort — clear local state regardless
      }
    }
    await StorageService.instance.clearToken();
    customer.value = null;
    isLoggedIn.value = false;
  }

  /// Called by the network layer on any 401 — clears session and lets the
  /// router redirect to login without a further server round-trip.
  void forceLogout() {
    StorageService.instance.clearToken();
    customer.value = null;
    isLoggedIn.value = false;
  }
}
