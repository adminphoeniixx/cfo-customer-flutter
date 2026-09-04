import '../../core/utils/json_utils.dart';
import 'address.dart';

class OrderTotals {
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double shippingTotal;
  final double grandTotal;
  final double refundedTotal;

  OrderTotals({
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.shippingTotal,
    required this.grandTotal,
    required this.refundedTotal,
  });

  factory OrderTotals.fromJson(Map<String, dynamic> j) => OrderTotals(
    subtotal: asDouble(j['subtotal']),
    discountTotal: asDouble(j['discount_total']),
    taxTotal: asDouble(j['tax_total']),
    shippingTotal: asDouble(j['shipping_total']),
    grandTotal: asDouble(j['grand_total']),
    refundedTotal: asDouble(j['refunded_total']),
  );
}

class OrderItem {
  final int id;
  final int productId;
  final int? productVariantId;
  final int vendorId;
  final String name;
  final String? sku;
  final String? image;
  final Map<String, dynamic>? options;
  final double unitPrice;
  final int quantity;
  final int quantityCancelled;
  final int quantityRefunded;
  final int quantityFulfilled;
  final int quantityAvailable;
  final double total;
  final String fulfillmentStatus;

  OrderItem({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.vendorId,
    required this.name,
    this.sku,
    this.image,
    this.options,
    required this.unitPrice,
    required this.quantity,
    required this.quantityCancelled,
    required this.quantityRefunded,
    required this.quantityFulfilled,
    required this.quantityAvailable,
    required this.total,
    required this.fulfillmentStatus,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: asInt(j['id']),
    productId: asInt(j['product_id']),
    productVariantId: j['product_variant_id'] == null
        ? null
        : asInt(j['product_variant_id']),
    vendorId: asInt(j['vendor_id']),
    name: asString(j['name']),
    sku: j['sku'],
    image: j['image'] ?? j['emoji'] ?? j['icon'],
    options: j['options'] == null
        ? null
        : Map<String, dynamic>.from(j['options']),
    unitPrice: asDouble(j['unit_price']),
    quantity: asInt(j['quantity']),
    quantityCancelled: asInt(j['quantity_cancelled']),
    quantityRefunded: asInt(j['quantity_refunded']),
    quantityFulfilled: asInt(j['quantity_fulfilled']),
    quantityAvailable: asInt(j['quantity_available']),
    total: asDouble(j['total']),
    fulfillmentStatus: asString(j['fulfillment_status']),
  );
}

class OrderSeller {
  final int id;
  final String name;
  final String? city;
  OrderSeller({required this.id, required this.name, this.city});
  factory OrderSeller.fromJson(Map<String, dynamic> j) => OrderSeller(
    id: asInt(j['id']),
    name: asString(j['name']),
    city: j['city'],
  );
}

class OrderTimelineEvent {
  final String type;
  final String title;
  final DateTime? at;
  final String state;
  OrderTimelineEvent({
    required this.type,
    required this.title,
    this.at,
    this.state = '',
  });
  factory OrderTimelineEvent.fromJson(Map<String, dynamic> j) =>
      OrderTimelineEvent(
        type: asString(j['type'] ?? j['key'] ?? j['status']),
        title: asString(j['title'] ?? j['label']),
        at: j['at'] == null && j['happened_at'] == null
            ? null
            : DateTime.tryParse('${j['at'] ?? j['happened_at']}'),
        state: asString(j['state']),
      );
}

class Order {
  final int id;
  final String number;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String fulfillmentStatus;
  final String paymentMethod;
  final String shippingMethod;
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? invoiceUrl;
  final String? eta;
  final String? transactionId;
  final bool? paymentRequired;
  final String? couponCode;
  final String? customerNote;
  final Address? shippingAddress;
  final OrderTotals totals;
  final List<OrderItem> items;
  final List<OrderSeller> sellers;
  final bool canCancel;
  final bool canReturn;
  final DateTime? placedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final List<OrderTimelineEvent> timeline;

  Order({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    required this.paymentMethod,
    required this.shippingMethod,
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    this.invoiceUrl,
    this.eta,
    this.transactionId,
    this.paymentRequired,
    this.couponCode,
    this.customerNote,
    this.shippingAddress,
    required this.totals,
    required this.items,
    required this.sellers,
    required this.canCancel,
    required this.canReturn,
    this.placedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.timeline,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: asInt(j['id']),
    number: asString(j['number']),
    status: asString(j['status']),
    statusLabel: asString(j['status_label']),
    paymentStatus: asString(j['payment_status']),
    fulfillmentStatus: asString(j['fulfillment_status']),
    paymentMethod: asString(j['payment_method']),
    shippingMethod: asString(j['shipping_method']),
    carrier: j['carrier'],
    trackingNumber: j['tracking_number'],
    trackingUrl: j['tracking_url'],
    invoiceUrl: j['invoice_url'],
    eta: j['eta'] ?? j['eta_label'],
    transactionId: j['transaction_id'],
    paymentRequired: j['payment_required'] == null ? null : asBool(j['payment_required']),
    couponCode: j['coupon_code'],
    customerNote: j['customer_note'],
    shippingAddress: j['shipping_address'] == null
        ? null
        : Address.fromJson({
            'id': 0,
            ...Map<String, dynamic>.from(j['shipping_address']),
          }),
    totals: OrderTotals.fromJson(Map<String, dynamic>.from(j['totals'] ?? {})),
    items: (j['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    sellers: (j['sellers'] as List? ?? [])
        .map((e) => OrderSeller.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    canCancel: asBool(j['can_cancel']),
    canReturn: asBool(j['can_return']),
    placedAt: j['placed_at'] == null ? null : DateTime.tryParse(j['placed_at']),
    paidAt: j['paid_at'] == null ? null : DateTime.tryParse(j['paid_at']),
    shippedAt: j['shipped_at'] == null
        ? null
        : DateTime.tryParse(j['shipped_at']),
    deliveredAt: j['delivered_at'] == null
        ? null
        : DateTime.tryParse(j['delivered_at']),
    cancelledAt: j['cancelled_at'] == null
        ? null
        : DateTime.tryParse(j['cancelled_at']),
    timeline: (j['timeline'] as List? ?? [])
        .map((e) => OrderTimelineEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class OrderTrack {
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? supportPhone;
  final String? etaLabel;
  final List<OrderTimelineEvent> milestones;

  OrderTrack({
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    this.supportPhone,
    this.etaLabel,
    required this.milestones,
  });

  factory OrderTrack.fromJson(Map<String, dynamic> j) => OrderTrack(
    carrier: j['carrier'] is Map
        ? Map<String, dynamic>.from(j['carrier'])['name']
        : j['carrier'],
    trackingNumber: j['tracking_number'],
    trackingUrl: j['tracking_url'],
    supportPhone: j['support_phone'] ??
        (j['carrier'] is Map
            ? Map<String, dynamic>.from(j['carrier'])['support_phone']
            : null),
    etaLabel: j['eta_label'] ?? j['eta'],
    milestones: (j['events'] as List? ??
            j['milestones'] as List? ??
            j['timeline'] as List? ??
            [])
        .map((e) => OrderTimelineEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class ReorderResult {
  final List<String> added;
  final List<String> skipped;
  ReorderResult({required this.added, required this.skipped});
  factory ReorderResult.fromJson(Map<String, dynamic> j) => ReorderResult(
    added: (j['added'] as List? ?? []).map((e) => e.toString()).toList(),
    skipped: (j['skipped'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}
