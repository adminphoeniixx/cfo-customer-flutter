import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_exception.dart';
import '../../core/utils/json_utils.dart';
import '../models/checkout.dart';

/// `POST /payments/create-intent`. [gateway] names the SDK to open and
/// [checkout] is exactly what that SDK needs, passed through unchanged.
class PaymentIntent {
  /// `razorpay` or `cashfree`.
  final String gateway;

  /// `test` or `live`.
  final String? mode;
  final Map<String, dynamic> checkout;

  /// What is charged, in rupees — already net of store credit.
  final double amount;
  final String currency;

  PaymentIntent({
    required this.gateway,
    this.mode,
    required this.checkout,
    required this.amount,
    required this.currency,
  });

  bool get isRazorpay => gateway == 'razorpay';
  bool get isCashfree => gateway == 'cashfree';

  factory PaymentIntent.fromJson(Map<String, dynamic> j) {
    final checkout = j['checkout'] is Map
        ? Map<String, dynamic>.from(j['checkout'])
        : <String, dynamic>{};
    // Older responses carried the Razorpay fields at the top level only.
    final gateway = asString(j['gateway'], 'razorpay');
    if (gateway == 'razorpay') {
      checkout['key'] ??= j['razorpay_key'] ?? j['key'];
      checkout['order_id'] ??=
          j['gateway_order_id'] ?? j['razorpay_order_id'] ?? j['order_id'];
      checkout['currency'] ??= j['currency'] ?? 'INR';
    }
    var amount = asDouble(j['amount']);
    // Razorpay's `checkout.amount` is in paise; if the top-level figure
    // matches it, it is paise too.
    final paise = asNum(checkout['amount']);
    if (gateway == 'razorpay' && paise != null && paise == amount) {
      amount = paise / 100;
    }
    return PaymentIntent(
      gateway: gateway,
      mode: j['mode']?.toString(),
      checkout: checkout,
      amount: amount,
      currency: asString(j['currency'] ?? checkout['currency'], 'INR'),
    );
  }
}

class PaymentsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Which gateway is switched on in the admin panel. No token needed.
  Future<PaymentGatewayConfig> config() async {
    final res = await _api.get('/payments/config');
    final data = res.data is Map ? res.data['data'] : null;
    return data is Map
        ? PaymentGatewayConfig.fromJson(Map<String, dynamic>.from(data))
        : PaymentGatewayConfig.off;
  }

  Future<PaymentIntent> createIntent({required int orderId}) async {
    final res = await _api.post(
      '/payments/create-intent',
      data: {'order_id': orderId},
    );
    final intent = PaymentIntent.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
    // Fail loudly here rather than handing the SDK an empty session — that
    // fails deep inside native code with a far less useful message.
    final c = intent.checkout;
    final ready = switch (intent.gateway) {
      'razorpay' =>
        asString(c['key']).isNotEmpty && asString(c['order_id']).isNotEmpty,
      'cashfree' =>
        asString(c['payment_session_id']).isNotEmpty &&
            asString(c['order_id']).isNotEmpty,
      _ => false,
    };
    if (!ready) {
      throw AppException(
        message: 'Payment could not be started. Please try again.',
        type: AppExceptionType.unknown,
      );
    }
    return intent;
  }

  Future<void> verifyRazorpay({
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

  /// Cashfree: the server asks Cashfree itself. A 422 "not received yet"
  /// means Cashfree has not settled it yet — retried a few times here.
  Future<void> verifyCashfree({required String orderNumber}) async {
    const attempts = 5;
    for (var i = 1; ; i++) {
      try {
        await _api.post(
          '/payments/verify',
          data: {'order_number': orderNumber.replaceFirst('#', '')},
        );
        return;
      } on AppException catch (e) {
        final pending =
            e.statusCode == 422 &&
            e.message.toLowerCase().contains('not received');
        if (!pending || i >= attempts) rethrow;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }
}
