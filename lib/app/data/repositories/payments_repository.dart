import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_exception.dart';
import '../../core/utils/json_utils.dart';

class PaymentIntent {
  final String razorpayOrderId;
  final String razorpayKey;
  final int amount;
  final String currency;

  PaymentIntent({
    required this.razorpayOrderId,
    required this.razorpayKey,
    required this.amount,
    required this.currency,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> j) => PaymentIntent(
    razorpayOrderId: asString(
      j['razorpay_order_id'] ?? j['order_id'] ?? j['id'],
    ),
    razorpayKey: asString(j['razorpay_key'] ?? j['key']),
    amount: asInt(j['amount']),
    currency: asString(j['currency'], 'INR'),
  );
}

class PaymentsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  Future<PaymentIntent> createIntent({required int orderId}) async {
    final res = await _api.post(
      '/payments/create-intent',
      data: {'order_id': orderId},
    );
    final intent = PaymentIntent.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
    // Fail loudly here rather than handing Razorpay an empty key/order id —
    // that fails deep inside the native SDK with a far less useful message.
    if (intent.razorpayKey.isEmpty ||
        intent.razorpayOrderId.isEmpty ||
        intent.amount <= 0) {
      throw AppException(
        message: 'Payment could not be started. Please try again.',
        type: AppExceptionType.unknown,
      );
    }
    return intent;
  }

  Future<void> verify({
    required int orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) => _api.post(
    '/payments/verify',
    data: {
      'order_id': orderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
    },
  );
}
