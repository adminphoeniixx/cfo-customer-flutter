import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/app_exception.dart';
import '../../data/models/address.dart';
import '../../data/models/cart.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/checkout_repository.dart';
import '../checkout/checkout_controller.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';

class CartController extends GetxController {
  final CartRepository _repo = Get.find<CartRepository>();
  final CheckoutRepository _checkoutRepo = Get.find<CheckoutRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final Rxn<CartResponse> cart = Rxn<CartResponse>();
  final Rxn<Address> deliveryAddress = Rxn<Address>();
  final RxBool loading = true.obs;
  final RxBool busy = false.obs;
  final RxString couponInput = ''.obs;
  final RxString couponError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.isLoggedIn, (_) => load());
    load();
  }

  Future<void> load() async {
    if (!_auth.isLoggedIn.value) {
      cart.value = CartResponse.empty();
      deliveryAddress.value = null;
      loading.value = false;
      return;
    }
    loading.value = cart.value == null;
    try {
      final nextCart = await _repo.getCart();
      cart.value = nextCart;
      if (nextCart.lineCount > 0) {
        await _loadDeliveryAddress();
      } else {
        deliveryAddress.value = null;
      }
    } catch (_) {
      if (cart.value == null) cart.value = CartResponse.empty();
      deliveryAddress.value ??= null;
      CfoToast.error('Could not load your cart. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadDeliveryAddress() async {
    try {
      final checkout = await _checkoutRepo.getCheckout();
      deliveryAddress.value =
          checkout.addresses.firstWhereOrNull(
            (a) => a.id == checkout.selectedAddressId,
          ) ??
          checkout.addresses.firstWhereOrNull((a) => a.isDefaultShipping) ??
          checkout.addresses.firstOrNull;
    } catch (_) {
      deliveryAddress.value = null;
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    busy.value = true;
    try {
      cart.value = await _repo.updateItem(itemId, quantity);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      busy.value = false;
    }
  }

  Future<void> removeItem(int itemId) async {
    busy.value = true;
    try {
      cart.value = await _repo.removeItem(itemId);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      busy.value = false;
    }
  }

  Future<void> saveForLater(int itemId) async {
    busy.value = true;
    try {
      cart.value = await _repo.saveForLater(itemId);
    } finally {
      busy.value = false;
    }
  }

  Future<void> moveToCart(int itemId) async {
    busy.value = true;
    try {
      cart.value = await _repo.moveToCart(itemId);
    } finally {
      busy.value = false;
    }
  }

  Future<void> applyCoupon(String code) async {
    if (code.trim().isEmpty) return;
    busy.value = true;
    couponError.value = '';
    try {
      cart.value = await _repo.applyCoupon(code.trim());
    } on AppException catch (e) {
      couponError.value = e.message;
    } finally {
      busy.value = false;
    }
  }

  Future<void> removeCoupon() async {
    busy.value = true;
    try {
      cart.value = await _repo.removeCoupon();
    } finally {
      busy.value = false;
    }
  }

  Future<List<AvailableCoupon>> availableCoupons() => _repo.availableCoupons();

  void goToCheckout() {
    if (!_auth.isLoggedIn.value) {
      Get.toNamed(
        AppRoutes.login,
        arguments: {'redirect': AppRoutes.checkoutAddress},
      );
      return;
    }
    // A checkout session started earlier in this app run would otherwise be
    // reused as-is (its address/shipping/payment summary loaded once and
    // never refetched), so a newly added address or a cart change made
    // since then wouldn't show up. Starting fresh from the cart should
    // always mean a fresh quote.
    if (Get.isRegistered<CheckoutController>()) {
      Get.delete<CheckoutController>();
    }
    Get.toNamed(AppRoutes.checkoutAddress);
  }
}
