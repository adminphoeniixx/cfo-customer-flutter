import '../../core/utils/json_utils.dart';
import 'address.dart';
import 'cart.dart';

class PaymentMethodOption {
  final String code;
  final String name;
  final String? description;
  final String? icon;
  final bool isPayOnDelivery;
  final bool isAvailable;
  final String? unavailableReason;
  PaymentMethodOption({
    required this.code,
    required this.name,
    this.description,
    this.icon,
    this.isPayOnDelivery = false,
    this.isAvailable = true,
    this.unavailableReason,
  });
  factory PaymentMethodOption.fromJson(Map<String, dynamic> j) =>
      PaymentMethodOption(
        code: asString(j['code']),
        name: asString(j['name']),
        description: j['description'],
        icon: j['icon']?.toString(),
        isPayOnDelivery: asBool(j['is_pay_on_delivery']),
        isAvailable: asBool(j['is_available'], true),
        unavailableReason: j['unavailable_reason']?.toString(),
      );
}

class CheckoutItem {
  final int cartItemId;
  final int productId;
  final int? productVariantId;
  final int vendorId;
  final String name;
  final String? sku;
  final String? image;
  final double unitPrice;
  final double? mrp;
  final int quantity;
  final double total;
  final bool inStock;
  final int? available;

  CheckoutItem({
    required this.cartItemId,
    required this.productId,
    this.productVariantId,
    required this.vendorId,
    required this.name,
    this.sku,
    this.image,
    required this.unitPrice,
    this.mrp,
    required this.quantity,
    required this.total,
    required this.inStock,
    this.available,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> j) => CheckoutItem(
    cartItemId: asInt(j['cart_item_id']),
    productId: asInt(j['product_id']),
    productVariantId: j['product_variant_id'] == null
        ? null
        : asInt(j['product_variant_id']),
    vendorId: asInt(j['vendor_id']),
    name: asString(j['name']),
    sku: j['sku'],
    image: j['image'] ?? j['emoji'] ?? j['icon'],
    unitPrice: asDouble(j['unit_price']),
    mrp: j['mrp'] == null ? null : asDouble(j['mrp']),
    quantity: asInt(j['quantity']),
    total: asDouble(j['total']),
    inStock: asBool(j['in_stock'], true),
    available: j['available'] == null ? null : asInt(j['available']),
  );
}

class CheckoutSummary {
  final List<Address> addresses;
  final int? selectedAddressId;
  final List<ShippingOption> shippingOptions;
  final String? selectedShippingCode;
  final List<PaymentMethodOption> paymentMethods;
  final AppliedCoupon? coupon;
  final CartTotals totals;
  final List<CheckoutItem> items;

  /// Which gateway the admin panel has switched on (`payment_gateway`).
  final PaymentGatewayConfig? paymentGateway;

  CheckoutSummary({
    required this.addresses,
    this.selectedAddressId,
    required this.shippingOptions,
    this.selectedShippingCode,
    required this.paymentMethods,
    this.coupon,
    required this.totals,
    required this.items,
    this.paymentGateway,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> j) => CheckoutSummary(
    addresses: (j['addresses'] as List? ?? [])
        .map((e) => Address.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    selectedAddressId: j['selected_address_id'] == null
        ? null
        : asInt(j['selected_address_id']),
    shippingOptions: (j['shipping_options'] as List? ?? [])
        .map((e) => ShippingOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    selectedShippingCode: j['selected_shipping_code'],
    paymentMethods: (j['payment_methods'] as List? ?? [])
        .map((e) => PaymentMethodOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    coupon: j['coupon'] == null
        ? null
        : AppliedCoupon.fromJson(Map<String, dynamic>.from(j['coupon'])),
    totals: CartTotals.fromJson(Map<String, dynamic>.from(j['totals'] ?? {})),
    items: (j['items'] as List? ?? [])
        .map((e) => CheckoutItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    paymentGateway: j['payment_gateway'] is Map
        ? PaymentGatewayConfig.fromJson(
            Map<String, dynamic>.from(j['payment_gateway']),
          )
        : null,
  );
}

/// `GET /payments/config`, also sent as `payment_gateway` on `/checkout`.
/// Only public values ever arrive here — never a key secret.
class PaymentGatewayConfig {
  final bool enabled;

  /// `razorpay` or `cashfree`; null when no gateway is on.
  final String? gateway;
  final String? name;

  /// `test` or `live`.
  final String? mode;
  final Map<String, dynamic> config;

  const PaymentGatewayConfig({
    required this.enabled,
    this.gateway,
    this.name,
    this.mode,
    this.config = const {},
  });

  /// No gateway on: online orders are settled on placement, no SDK opens.
  static const off = PaymentGatewayConfig(enabled: false);

  bool get isTest => mode == 'test';

  factory PaymentGatewayConfig.fromJson(Map<String, dynamic> j) =>
      PaymentGatewayConfig(
        enabled: asBool(j['enabled']) && j['gateway'] != null,
        gateway: j['gateway']?.toString(),
        name: j['name']?.toString(),
        mode: j['mode']?.toString(),
        config: j['config'] is Map
            ? Map<String, dynamic>.from(j['config'])
            : const {},
      );
}
