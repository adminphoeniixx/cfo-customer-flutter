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

/// Cash on Delivery's reference code — placed directly with no gateway.
const kCodPaymentMethods = {'cod', 'cash-on-delivery'};

/// Shared across the three checkout steps (address -> delivery -> payment)
/// so the quote and selections persist between them.
class CheckoutController extends GetxController {
  final CheckoutRepository _repo = Get.find<CheckoutRepository>();
  final AccountRepository _accountRepo = Get.find<AccountRepository>();
  final PaymentsRepository _paymentsRepo = Get.find<PaymentsRepository>();
  late final Razorpay _razorpay;
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

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);
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
      final available = s.paymentMethods.where((m) => m.isAvailable);
      if (available.isNotEmpty) {
        selectedPaymentMethod.value = available.first.code;
      } else if (s.paymentMethods.isNotEmpty) {
        selectedPaymentMethod.value = s.paymentMethods.first.code;
      }
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
    } finally {
      loading.value = false;
    }
  }

  Future<void> placeOrder() async {
    if (selectedAddressId.value == null ||
        selectedShippingCode.value.isEmpty ||
        selectedPaymentMethod.value.isEmpty) {
      CfoToast.error(
        'Please choose an address, delivery option and payment method.',
      );
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
      // for COD this is the whole flow; for a gateway method the order
      // exists (payment_status: pending) before we ever touch Razorpay.
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
      _razorpay.open({
        'key': intent.razorpayKey,
        'order_id': intent.razorpayOrderId,
        'amount': intent.amount,
        'currency': intent.currency,
        'name': 'CFO Shop',
        'description': 'Order ${order.number}',
        'prefill': {},
        'theme': {'color': '#dd2f60'},
      });
    } on AppException catch (e) {
      error.value = e.message;
      CfoToast.error(e.message);
      placing.value = false;
      _recoverToPendingOrder();
    } catch (e) {
      error.value = '$e';
      CfoToast.error('Could not open payment. Please try again.');
      placing.value = false;
      _recoverToPendingOrder();
    }
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
      await _paymentsRepo.verify(
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
