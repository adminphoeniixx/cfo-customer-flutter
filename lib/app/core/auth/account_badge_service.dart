import 'package:get/get.dart';
import '../../data/repositories/account_repository.dart';
import 'auth_service.dart';

/// App-wide "things needing attention" count for the Account tab (delivered
/// orders with no rating yet) — same pattern as [NotificationsBadgeService],
/// backed by `GET /me/summary`.
class AccountBadgeService extends GetxService {
  final AccountRepository _repo = Get.find<AccountRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final RxInt pendingReviewsCount = 0.obs;

  Future<AccountBadgeService> init() async {
    ever(_auth.isLoggedIn, (_) => refresh());
    if (_auth.isLoggedIn.value) await refresh();
    return this;
  }

  Future<void> refresh() async {
    if (!_auth.isLoggedIn.value) {
      pendingReviewsCount.value = 0;
      return;
    }
    try {
      final summary = await _repo.summary();
      pendingReviewsCount.value = summary.reviewsPendingCount;
    } catch (_) {
      // leave previous value on transient failure
    }
  }
}
