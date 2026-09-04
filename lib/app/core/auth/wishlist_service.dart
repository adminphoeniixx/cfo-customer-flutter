import 'package:get/get.dart';
import '../../data/repositories/account_repository.dart';
import 'auth_service.dart';

/// App-wide wishlist membership, so the heart icon on a product card shows
/// the same state everywhere it appears (Home, Results, Search, Product
/// detail, Wishlist tab) without each screen needing its own refresh.
/// Put once at startup as a permanent GetxService and read/written by every
/// screen that shows or toggles a wishlist heart.
class WishlistService extends GetxService {
  final AccountRepository _repo = Get.find<AccountRepository>();
  final AuthService _auth = Get.find<AuthService>();

  /// Product ids currently in the customer's wishlist.
  final RxSet<int> ids = <int>{}.obs;
  final RxBool loaded = false.obs;

  Future<WishlistService> init() async {
    ever(_auth.isLoggedIn, (_) => refresh());
    if (_auth.isLoggedIn.value) await refresh();
    return this;
  }

  Future<void> refresh() async {
    if (!_auth.isLoggedIn.value) {
      ids.clear();
      loaded.value = false;
      return;
    }
    try {
      final products = await _repo.wishlist();
      ids
        ..clear()
        ..addAll(products.map((p) => p.id));
      loaded.value = true;
    } catch (_) {
      // leave previous state on transient failure
    }
  }

  bool isWishlisted(int productId) => ids.contains(productId);

  /// Optimistically flips membership, calls the API, and rolls back on
  /// failure. Every screen using this converges on the same [ids] set, so
  /// toggling anywhere updates every heart icon immediately.
  Future<void> toggle(int productId) async {
    final was = ids.contains(productId);
    if (was) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    try {
      if (was) {
        await _repo.removeFromWishlist(productId);
      } else {
        await _repo.addToWishlist(productId);
      }
    } catch (_) {
      // roll back on failure
      if (was) {
        ids.add(productId);
      } else {
        ids.remove(productId);
      }
      rethrow;
    }
  }
}
