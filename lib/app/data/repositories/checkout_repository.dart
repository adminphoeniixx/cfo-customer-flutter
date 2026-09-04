import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/checkout.dart';
import '../models/order.dart';

class CheckoutRepository {
  final ApiClient _api = Get.find<ApiClient>();

  Future<CheckoutSummary> getCheckout() async {
    final res = await _api.get('/checkout');
    return CheckoutSummary.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Order> placeOrder({
    required int addressId,
    required String paymentMethod,
    required String shippingCode,
    String? note,
  }) async {
    final res = await _api.post('/orders', data: {
      'address_id': addressId,
      'payment_method': paymentMethod,
      'shipping_code': shippingCode,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return Order.fromJson(Map<String, dynamic>.from(res.data['data']));
  }
}
