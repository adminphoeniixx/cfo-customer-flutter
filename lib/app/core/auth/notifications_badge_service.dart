import 'package:get/get.dart';
import '../../data/repositories/account_repository.dart';
import 'auth_service.dart';

/// App-wide unread notification count, so the bell badge in the header
/// agrees with the Notifications screen without a manual refresh — same
/// pattern as [WishlistService].
class NotificationsBadgeService extends GetxService {
  final AccountRepository _repo = Get.find<AccountRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final RxInt unreadCount = 0.obs;

  Future<NotificationsBadgeService> init() async {
    ever(_auth.isLoggedIn, (_) => refresh());
    if (_auth.isLoggedIn.value) await refresh();
    return this;
  }

  Future<void> refresh() async {
    if (!_auth.isLoggedIn.value) {
      unreadCount.value = 0;
      return;
    }
    try {
      unreadCount.value = await _repo.unreadCount();
    } catch (_) {
      // leave previous value on transient failure
    }
  }
}
