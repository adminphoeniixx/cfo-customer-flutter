import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/network/app_exception.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../cart/cart_controller.dart';

class ProductDetailController extends GetxController {
  final CatalogRepository _catalog = Get.find<CatalogRepository>();
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final WishlistService _wishlist = Get.find<WishlistService>();
  final AuthService _auth = Get.find<AuthService>();

  late String idOrSlug;
  final Rxn<ProductDetail> product = Rxn<ProductDetail>();
  final RxBool loading = true.obs;
  final RxBool addingToCart = false.obs;
  final RxBool togglingWishlist = false.obs;
  final RxMap<String, String> selectedOptions = <String, String>{}.obs;
  final RxInt quantity = 1.obs;

  /// Reads live from the app-wide [WishlistService] so this screen always
  /// agrees with the heart shown on product cards elsewhere.
  bool get isWishlisted =>
      product.value != null && _wishlist.isWishlisted(product.value!.id);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    idOrSlug = args is Map ? (args['idOrSlug']?.toString() ?? '') : '';
    load();
  }

  Future<void> load() async {
    loading.value = product.value == null;
    try {
      product.value = await _catalog.product(idOrSlug);
    } finally {
      loading.value = false;
    }
  }

  void selectOption(String name, String value) {
    selectedOptions[name] = value;
  }

  ProductVariant? get matchedVariant {
    final p = product.value;
    if (p == null || !p.isVariable) return null;
    for (final v in p.variants) {
      final matches = v.options.entries.every(
        (e) => selectedOptions[e.key] == e.value,
      );
      if (matches && v.options.length == selectedOptions.length) return v;
    }
    return null;
  }

  /// Returns true on success so [buyNow] knows whether to continue to checkout.
  Future<bool> addToCart({bool silent = false}) async {
    final p = product.value;
    if (p == null) return false;
    if (!_auth.isLoggedIn.value) {
      Get.toNamed(AppRoutes.login);
      return false;
    }
    if (p.isVariable && matchedVariant == null) {
      CfoToast.show(
        'Please select ${p.options.map((o) => o.name).join(' and ')} first.',
      );
      return false;
    }
    addingToCart.value = true;
    try {
      final cart = await _cartRepo.addItem(
        productId: p.id,
        productVariantId: matchedVariant?.id,
        quantity: quantity.value,
      );
      // Push the freshly priced basket into the shared CartController so the
      // cart badge/tab update immediately without a manual refresh.
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().cart.value = cart;
      }
      if (!silent) CfoToast.success('Added to cart');
      return true;
    } on AppException catch (e) {
      CfoToast.error(e.message);
      return false;
    } finally {
      addingToCart.value = false;
    }
  }

  /// Matches the prototype's BUY NOW: add the line, then go straight to checkout.
  Future<void> buyNow() async {
    final ok = await addToCart(silent: true);
    if (ok) Get.find<CartController>().goToCheckout();
  }

  Future<void> toggleWishlist() async {
    final p = product.value;
    if (p == null) return;
    if (!_auth.isLoggedIn.value) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    togglingWishlist.value = true;
    try {
      await _wishlist.toggle(p.id);
    } catch (_) {
      // best-effort; WishlistService already rolled its own state back
    } finally {
      togglingWishlist.value = false;
    }
  }
}
