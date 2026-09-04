import 'package:get/get.dart';
import '../../core/cache/cache_service.dart';
import '../../core/network/api_client.dart';
import '../models/cart.dart';

/// Every call here returns the whole priced basket — see customer-api.md.
class CartRepository {
  final ApiClient _api = Get.find<ApiClient>();

  CartResponse _parse(dynamic data) => CartResponse.fromJson(Map<String, dynamic>.from(data['data']));

  void _bustDependentCaches() {
    // Cart mutations can change free-shipping eligibility shown elsewhere.
    CacheService.instance.invalidate('checkout');
  }

  Future<CartResponse> getCart() async => _parse((await _api.get('/cart')).data);

  Future<CartResponse> addItem({required int productId, int? productVariantId, int quantity = 1}) async {
    final res = await _api.post('/cart/items', data: {
      'product_id': productId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
    });
    _bustDependentCaches();
    return _parse(res.data);
  }

  Future<CartResponse> updateItem(int itemId, int quantity) async {
    final res = await _api.patch('/cart/items/$itemId', data: {'quantity': quantity});
    _bustDependentCaches();
    return _parse(res.data);
  }

  Future<CartResponse> removeItem(int itemId) async {
    final res = await _api.delete('/cart/items/$itemId');
    _bustDependentCaches();
    return _parse(res.data);
  }

  Future<CartResponse> clearCart() async {
    final res = await _api.delete('/cart');
    _bustDependentCaches();
    return _parse(res.data);
  }

  Future<CartResponse> saveForLater(int itemId) async {
    final res = await _api.post('/cart/items/$itemId/save-for-later');
    return _parse(res.data);
  }

  Future<CartResponse> moveToCart(int itemId) async {
    final res = await _api.post('/cart/items/$itemId/move-to-cart');
    return _parse(res.data);
  }

  Future<List<AvailableCoupon>> availableCoupons() async {
    final res = await _api.get('/cart/coupons');
    return (res.data['data'] as List).map((e) => AvailableCoupon.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<CartResponse> applyCoupon(String code) async {
    final res = await _api.post('/cart/coupon', data: {'code': code});
    _bustDependentCaches();
    return _parse(res.data);
  }

  Future<CartResponse> removeCoupon() async {
    final res = await _api.delete('/cart/coupon');
    _bustDependentCaches();
    return _parse(res.data);
  }
}
