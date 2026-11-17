import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/network/app_exception.dart';
import '../../data/models/checkout.dart';
import '../../data/models/address.dart';
import '../../data/models/order.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/checkout_repository.dart';
import '../../data/repositories/payments_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../cart/cart_controller.dart';
import 'unavailable_items_sheet.dart';

/// Shared across the three checkout steps (address -> delivery -> payment)
/// so the quote and selections persist between them.
class CheckoutController extends GetxController {
  final CheckoutRepository _repo = Get.find<CheckoutRepository>();
  final AccountRepository _accountRepo = Get.find<AccountRepository>();
  final PaymentsRepository _paymentsRepo = Get.find<PaymentsRepository>();
  late final Razorpay _razorpay;
  final CFPaymentGatewayService _cashfree = CFPaymentGatewayService();
  Order? _pendingOrder;

  final Rxn<CheckoutSummary> summary = Rxn<CheckoutSummary>();
  final RxBool loading = true.obs;
  final RxnInt selectedAddressId = RxnInt();
  final RxString selectedShippingCode = ''.obs;
  final RxString selectedPaymentMethod = ''.obs;
  final RxString note = ''.obs;
  final RxBool placing = false.obs;
  final RxBool addressBusy = false.obs;
  final RxString error = ''.obs;

  /// What the gateway is charging, from `create-intent` (net of store
  /// credit). Null until a payment has been started.
  final Rxn<double> chargeAmount = Rxn<double>();

  /// The gateway the admin panel has switched on.
  final Rx<PaymentGatewayConfig> gateway = PaymentGatewayConfig.off.obs;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);
    _cashfree.setCallback(_onCashfreeVerify, _onCashfreeError);
    load();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = summary.value == null;
    try {
      final s = await _repo.getCheckout();
      summary.value = s;
      selectedAddressId.value =
          s.selectedAddressId ??
          (s.addresses.isNotEmpty ? s.addresses.first.id : null);
      selectedShippingCode.value =
          s.selectedShippingCode ??
          (s.shippingOptions.isNotEmpty ? s.shippingOptions.first.code : '');
      selectedPaymentMethod.value = _onlineCode(s.paymentMethods) ?? '';
      gateway.value = s.paymentGateway ?? await _loadGatewayConfig();
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
    } finally {
      loading.value = false;
    }
  }

  Future<PaymentGatewayConfig> _loadGatewayConfig() async {
    try {
      return await _paymentsRepo.config();
    } on AppException {
      return gateway.value;
    }
  }

  /// Every order is paid in the gateway's own checkout (whichever one the
  /// admin panel has switched on), where the shopper picks UPI, card, net
  /// banking or a wallet — so the first online code the API offers is sent.
  static String? _onlineCode(List<PaymentMethodOption> methods) {
    final online = methods.where((m) => m.isAvailable && !m.isPayOnDelivery);
    return online.isEmpty ? null : online.first.code;
  }

  Future<void> placeOrder() async {
    if (selectedAddressId.value == null || selectedShippingCode.value.isEmpty) {
      CfoToast.error('Please choose an address and delivery option.');
      return;
    }
    if (selectedPaymentMethod.value.isEmpty) {
      CfoToast.error('Online payment is unavailable right now.');
      return;
    }
    final chosenMethod = summary.value?.paymentMethods
        .where((m) => m.code == selectedPaymentMethod.value)
        .firstOrNull;
    if (chosenMethod != null && !chosenMethod.isAvailable) {
      CfoToast.error(
        chosenMethod.unavailableReason ?? 'This payment method is not available.',
      );
      return;
    }
    placing.value = true;
    error.value = '';
    try {
      // The quote is re-run and the order is created server-side first —
      // for COD, or with no gateway switched on, this is the whole flow;
      // otherwise the order exists (payment_status: pending) before any
      // gateway SDK is opened.
      final order = await _repo.placeOrder(
        addressId: selectedAddressId.value!,
        paymentMethod: selectedPaymentMethod.value,
        shippingCode: selectedShippingCode.value,
        note: note.value,
      );
      if (Get.isRegistered<CartController>()) Get.find<CartController>().load();

      if (order.paymentRequired != true) {
        _goToSuccess(order);
        return;
      }
      _pendingOrder = order;
      final intent = await _paymentsRepo.createIntent(orderId: order.id);
      if (intent.amount > 0) chargeAmount.value = intent.amount;
      _openGateway(intent, order);
    } on AppException catch (e) {
      placing.value = false;
      final unavailable = _pendingOrder == null ? _unavailableItems(e) : null;
      if (unavailable != null) {
        await _resolveUnavailableItems(unavailable);
        return;
      }
      error.value = e.message;
      CfoToast.error(e.message);
      _recoverToPendingOrder();
    } catch (e) {
      error.value = '$e';
      CfoToast.error('Could not open payment. Please try again.');
      placing.value = false;
      _recoverToPendingOrder();
    }
  }

  /// Opens the SDK that `create-intent` named, with its `checkout` block
  /// passed through as it came.
  void _openGateway(PaymentIntent intent, Order order) {
    if (intent.isRazorpay) {
      _razorpay.open({
        'name': 'CFO Shop',
        'description': 'Order ${order.number}',
        ...intent.checkout,
        'theme': {'color': '#4A5723'},
      });
      return;
    }
    if (intent.isCashfree) {
      final c = intent.checkout;
      final session = CFSessionBuilder()
          .setEnvironment(
            '${c['environment']}'.toUpperCase() == 'PRODUCTION'
                ? CFEnvironment.PRODUCTION
                : CFEnvironment.SANDBOX,
          )
          .setOrderId('${c['order_id']}')
          .setPaymentSessionId('${c['payment_session_id']}')
          .build();
      final theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor('#4A5723')
          .setNavigationBarTextColor('#FFFFFF')
          .setButtonBackgroundColor('#4A5723')
          .setButtonTextColor('#FFFFFF')
          .setPrimaryTextColor('#1B1D14')
          .setSecondaryTextColor('#4B4D44')
          .build();
      _cashfree.doPayment(
        CFWebCheckoutPaymentBuilder().setSession(session).setTheme(theme).build(),
      );
      return;
    }
    throw AppException(
      message: 'This payment option is not supported by the app yet.',
      type: AppExceptionType.unknown,
    );
  }

  /// `POST /orders` answers 422 with an error on `items` when a product in
  /// the cart came off sale. Returns the server's messages, or null for any
  /// other failure.
  static List<String>? _unavailableItems(AppException e) {
    if (e.statusCode != 422) return null;
    final errors = e.fieldErrors;
    if (errors == null) return null;
    final messages = [
      for (final entry in errors.entries)
        if (entry.key == 'items' || entry.key.startsWith('items.'))
          ...entry.value,
    ];
    return messages.isEmpty ? null : messages;
  }

  /// Lets the shopper drop the lines that are no longer on sale, then
  /// re-quotes the checkout so the totals match what will be charged.
  Future<void> _resolveUnavailableItems(List<String> messages) async {
    error.value = '';
    final cart = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : null;
    await cart?.load();
    final removed = await UnavailableItemsSheet.show(messages);
    if (!removed) return;
    if ((cart?.cart.value?.totals.itemsCount ?? 1) == 0) {
      CfoToast.show('Your cart is empty now.');
      Get.offAllNamed(AppRoutes.nav, arguments: {'tab': 3});
      return;
    }
    await load();
    CfoToast.success('Cart updated. You can place your order now.');
  }

  /// The order is already created server-side by the time create-intent or
  /// Razorpay.open() can fail — losing track of it here would strand a real
  /// `payment_status: pending` order with no way back to it. Route there
  /// instead of leaving the shopper stuck on the payment step.
  void _recoverToPendingOrder() {
    final order = _pendingOrder;
    if (order == null) return;
    _pendingOrder = null;
    Get.offNamed(AppRoutes.orderDetail, arguments: {'number': order.number});
  }

  Future<void> _onRazorpaySuccess(PaymentSuccessResponse response) async {
    final order = _pendingOrder;
    if (order == null) {
      placing.value = false;
      return;
    }
    try {
      await _paymentsRepo.verifyRazorpay(
        orderId: order.id,
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      _pendingOrder = null;
      _goToSuccess(order);
    } on AppException catch (e) {
      // The order already exists (payment captured, verification failed
      // client-side) — send the shopper to the order rather than retrying
      // placement, which would double-order.
      CfoToast.error(e.message);
      _pendingOrder = null;
      Get.offNamed(AppRoutes.orderDetail, arguments: {'number': order.number});
    } finally {
      placing.value = false;
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    placing.value = false;
    CfoToast.error(
      response.message ?? 'The payment was not completed. Please try again.',
    );
    // Order already placed as payment_status: pending — let the shopper
    // retry payment from the order screen instead of losing the order.
    _recoverToPendingOrder();
  }

  /// Cashfree reports success with its own order id only; the server
  /// checks the payment with Cashfree, keyed by our order number.
  Future<void> _onCashfreeVerify(String cashfreeOrderId) async {
    final order = _pendingOrder;
    if (order == null) {
      placing.value = false;
      return;
    }
    try {
      await _paymentsRepo.verifyCashfree(orderNumber: order.number);
      _pendingOrder = null;
      _goToSuccess(order);
    } on AppException catch (e) {
      // Paid at Cashfree but not confirmed yet — the webhook settles it.
      // Show the order rather than retrying placement.
      CfoToast.error(e.message);
      _pendingOrder = null;
      Get.offNamed(AppRoutes.orderDetail, arguments: {'number': order.number});
    } finally {
      placing.value = false;
    }
  }

  void _onCashfreeError(CFErrorResponse error, String cashfreeOrderId) {
    placing.value = false;
    CfoToast.error(
      error.getMessage() ?? 'The payment was not completed. Please try again.',
    );
    _recoverToPendingOrder();
  }

  void _onRazorpayExternalWallet(ExternalWalletResponse response) {
    placing.value = false;
    CfoToast.show(response.walletName ?? 'External wallet');
  }

  void _goToSuccess(Order order) {
    placing.value = false;
    Get.offNamed(AppRoutes.checkoutSuccess, arguments: {'order': order});
  }

  Future<void> editAddress(Address address) async {
    await Get.toNamed(AppRoutes.addressForm, arguments: {'address': address});
    await load();
  }

  Future<void> addAddress() async {
    await Get.toNamed(AppRoutes.addressForm);
    await load();
  }

  Future<void> deleteAddress(Address address) async {
    final addresses = summary.value?.addresses ?? [];
    if (addresses.length <= 1) {
      CfoToast.error('Keep at least one delivery address.');
      return;
    }
    addressBusy.value = true;
    try {
      await _accountRepo.deleteAddress(address.id);
      if (selectedAddressId.value == address.id) {
        selectedAddressId.value = addresses
            .firstWhere((a) => a.id != address.id)
            .id;
      }
      await load();
      CfoToast.success('Address deleted');
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      addressBusy.value = false;
    }
  }
}
