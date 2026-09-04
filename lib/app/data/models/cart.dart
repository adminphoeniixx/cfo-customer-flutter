import '../../core/utils/json_utils.dart';

class CartTotals {
  final int itemsCount;
  final double mrpTotal;
  final double subtotal;
  final double savedOnMrp;
  final double discountTotal;
  final double shippingTotal;
  final double taxTotal;
  final double grandTotal;

  CartTotals({
    required this.itemsCount,
    required this.mrpTotal,
    required this.subtotal,
    required this.savedOnMrp,
    required this.discountTotal,
    required this.shippingTotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  factory CartTotals.fromJson(Map<String, dynamic> j) => CartTotals(
    itemsCount: asInt(j['items_count']),
    mrpTotal: asDouble(j['mrp_total']),
    subtotal: asDouble(j['subtotal']),
    savedOnMrp: asDouble(j['saved_on_mrp']),
    discountTotal: asDouble(j['discount_total']),
    shippingTotal: asDouble(j['shipping_total']),
    taxTotal: asDouble(j['tax_total']),
    grandTotal: asDouble(j['grand_total']),
  );

  factory CartTotals.zero() => CartTotals(
    itemsCount: 0,
    mrpTotal: 0,
    subtotal: 0,
    savedOnMrp: 0,
    discountTotal: 0,
    shippingTotal: 0,
    taxTotal: 0,
    grandTotal: 0,
  );
}

class AppliedCoupon {
  final String code;
  final double discount;
  final bool coversShipping;
  AppliedCoupon({
    required this.code,
    required this.discount,
    required this.coversShipping,
  });
  factory AppliedCoupon.fromJson(Map<String, dynamic> j) => AppliedCoupon(
    code: asString(j['code']),
    discount: asDouble(j['discount']),
    coversShipping: asBool(j['covers_shipping']),
  );
}

class ShippingOption {
  final String code;
  final String name;
  final double rate;
  final String? freeBecause;
  final int? deliveryDaysMin;
  final int? deliveryDaysMax;
  final String? priceLabel;
  final String? apiEtaLabel;
  final String? note;

  ShippingOption({
    required this.code,
    required this.name,
    required this.rate,
    this.freeBecause,
    this.deliveryDaysMin,
    this.deliveryDaysMax,
    this.priceLabel,
    this.apiEtaLabel,
    this.note,
  });

  /// Display-ready ETA text — prefers the server's own copy, falls back to
  /// deriving it from delivery_days_min/max when the server sends null.
  String get etaLabel {
    if ((apiEtaLabel ?? '').isNotEmpty) return apiEtaLabel!;
    if (deliveryDaysMin == null || deliveryDaysMax == null) return '';
    return '$deliveryDaysMin–$deliveryDaysMax days';
  }

  factory ShippingOption.fromJson(Map<String, dynamic> j) => ShippingOption(
    code: asString(j['code']),
    name: asString(j['name']),
    rate: asDouble(j['rate']),
    freeBecause: j['free_because'],
    deliveryDaysMin: j['delivery_days_min'] == null
        ? null
        : asInt(j['delivery_days_min']),
    deliveryDaysMax: j['delivery_days_max'] == null
        ? null
        : asInt(j['delivery_days_max']),
    priceLabel: j['price_label']?.toString(),
    apiEtaLabel: j['eta_label']?.toString(),
    note: j['note']?.toString(),
  );
}

class CartItem {
  final int id;
  final int productId;
  final int? productVariantId;
  final String name;
  final String? sku;
  final Map<String, dynamic>? options;
  final String? image;
  final double unitPrice;
  final double? mrp;
  final int quantity;
  final double total;
  final bool inStock;
  final int? available;

  CartItem({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.name,
    this.sku,
    this.options,
    this.image,
    required this.unitPrice,
    this.mrp,
    required this.quantity,
    required this.total,
    required this.inStock,
    this.available,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    id: asInt(j['id']),
    productId: asInt(j['product_id']),
    productVariantId: j['product_variant_id'] == null
        ? null
        : asInt(j['product_variant_id']),
    name: asString(j['name']),
    sku: j['sku'],
    options: j['options'] == null
        ? null
        : Map<String, dynamic>.from(j['options']),
    image: j['image'] ?? j['emoji'] ?? j['icon'],
    unitPrice: asDouble(j['unit_price']),
    mrp: j['mrp'] == null ? null : asDouble(j['mrp']),
    quantity: asInt(j['quantity']),
    total: asDouble(j['total']),
    inStock: asBool(j['in_stock'], true),
    available: j['available'] == null ? null : asInt(j['available']),
  );
}

class CartGroup {
  final int vendorId;
  final String vendorName;
  final int itemsCount;
  final double subtotal;
  final List<CartItem> items;

  CartGroup({
    required this.vendorId,
    required this.vendorName,
    required this.itemsCount,
    required this.subtotal,
    required this.items,
  });

  factory CartGroup.fromJson(Map<String, dynamic> j) {
    final vendor = Map<String, dynamic>.from(j['vendor'] ?? {});
    return CartGroup(
      vendorId: asInt(vendor['id']),
      vendorName: asString(vendor['name']),
      itemsCount: asInt(j['items_count']),
      subtotal: asDouble(j['subtotal']),
      items: (j['items'] as List? ?? [])
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class CartResponse {
  final int id;
  final AppliedCoupon? coupon;
  final CartTotals totals;
  final List<ShippingOption> shippingOptions;
  final List<CartGroup> groups;
  final List<CartItem> savedForLater;

  CartResponse({
    required this.id,
    this.coupon,
    required this.totals,
    required this.shippingOptions,
    required this.groups,
    required this.savedForLater,
  });

  int get lineCount => groups.fold(0, (sum, g) => sum + g.items.length);

  factory CartResponse.fromJson(Map<String, dynamic> j) => CartResponse(
    id: asInt(j['id']),
    coupon: j['coupon'] == null
        ? null
        : AppliedCoupon.fromJson(Map<String, dynamic>.from(j['coupon'])),
    totals: CartTotals.fromJson(Map<String, dynamic>.from(j['totals'] ?? {})),
    shippingOptions: (j['shipping_options'] as List? ?? [])
        .map((e) => ShippingOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    groups: (j['groups'] as List? ?? [])
        .map((e) => CartGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    savedForLater: (j['saved_for_later'] as List? ?? [])
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  factory CartResponse.empty() => CartResponse(
    id: 0,
    coupon: null,
    totals: CartTotals.zero(),
    shippingOptions: [],
    groups: [],
    savedForLater: [],
  );
}

class AvailableCoupon {
  final String code;
  final String? description;
  final String type; // flat | percent | free_shipping
  final double value;
  final double? minSpend;
  final double discount;
  final bool usable;
  final String? reason; // e.g. "Add ₹400 more to use this."
  final bool applied;

  AvailableCoupon({
    required this.code,
    this.description,
    required this.type,
    required this.value,
    this.minSpend,
    required this.discount,
    required this.usable,
    this.reason,
    required this.applied,
  });

  factory AvailableCoupon.fromJson(Map<String, dynamic> j) => AvailableCoupon(
    code: asString(j['code']),
    description: j['description'],
    type: asString(j['type']),
    value: asDouble(j['value']),
    minSpend: j['min_spend'] == null ? null : asDouble(j['min_spend']),
    discount: asDouble(j['discount']),
    usable: asBool(j['usable']),
    reason: j['reason'],
    applied: asBool(j['applied']),
  );
}
