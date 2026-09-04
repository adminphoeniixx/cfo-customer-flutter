import '../../core/utils/json_utils.dart';

/// A merged row from `/requests` — a cancellation or a return, told apart by
/// `kind`.
class RequestItem {
  final int id;
  final String number;
  final String kind; // "cancellation" | "return"
  final String status; // pending, approved, rejected, withdrawn, ...
  final String? reason;
  final String? note;
  final String? method; // return only: original | ...
  final double? amount;
  final String? eta;
  final int orderId;
  final String? orderNumber;
  final bool refundRequested;
  final DateTime? createdAt;
  final List<RequestLineItem> items;

  RequestItem({
    required this.id,
    required this.number,
    required this.kind,
    required this.status,
    this.reason,
    this.note,
    this.method,
    this.amount,
    this.eta,
    required this.orderId,
    this.orderNumber,
    required this.refundRequested,
    this.createdAt,
    this.items = const [],
  });

  bool get canWithdraw => status == 'pending';
  bool get isCancellation => kind == 'cancellation';

  factory RequestItem.fromJson(Map<String, dynamic> j) => RequestItem(
    id: asInt(j['id']),
    number: asString(j['number'] ?? j['id']),
    kind: asString(j['kind']),
    status: asString(j['status']),
    reason: j['reason'],
    note: j['note'],
    method: j['method'],
    amount: j['amount'] == null ? null : asDouble(j['amount']),
    eta: j['eta'],
    orderId: asInt(j['order_id']),
    orderNumber: j['order_number'],
    refundRequested: asBool(j['refund_requested']),
    createdAt: j['created_at'] == null
        ? null
        : DateTime.tryParse(j['created_at']),
    items: (j['items'] as List? ?? [])
        .map((e) => RequestLineItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class RequestLineItem {
  final int orderItemId;
  final int quantity;
  final String? name;
  RequestLineItem({
    required this.orderItemId,
    required this.quantity,
    this.name,
  });
  factory RequestLineItem.fromJson(Map<String, dynamic> j) => RequestLineItem(
    orderItemId: asInt(j['order_item_id']),
    quantity: asInt(j['quantity']),
    name: j['name'],
  );
}
