import '../../core/utils/json_utils.dart';

class ReferenceCode {
  final String code; // "code" for payment/courier, "key" for reasons
  final String label;
  final String? description;
  ReferenceCode({required this.code, required this.label, this.description});

  factory ReferenceCode.fromJson(Map<String, dynamic> j) => ReferenceCode(
        code: asString(j['code'] ?? j['key']),
        label: asString(j['name'] ?? j['label']),
        description: j['description'] ?? j['support_phone'],
      );
}

class ReferenceData {
  final List<ReferenceCode> paymentMethods;
  final List<ReferenceCode> deliveryPartners;
  final List<ReferenceCode> cancellationReasons;
  final List<ReferenceCode> refundReasons;
  final List<ReferenceCode> refundMethods;
  final int? returnWindowDays;

  ReferenceData({
    required this.paymentMethods,
    required this.deliveryPartners,
    required this.cancellationReasons,
    required this.refundReasons,
    required this.refundMethods,
    this.returnWindowDays,
  });

  factory ReferenceData.fromJson(Map<String, dynamic> j) {
    List<ReferenceCode> list(String key) =>
        (j[key] as List? ?? []).map((e) => ReferenceCode.fromJson(Map<String, dynamic>.from(e))).toList();
    return ReferenceData(
      paymentMethods: list('payment_methods'),
      deliveryPartners: list('delivery_partners'),
      cancellationReasons: list('cancellation_reasons'),
      refundReasons: list('refund_reasons'),
      refundMethods: list('refund_methods'),
      returnWindowDays: j['return_window_days'] == null ? null : asInt(j['return_window_days']),
    );
  }

  factory ReferenceData.empty() => ReferenceData(
      paymentMethods: [], deliveryPartners: [], cancellationReasons: [], refundReasons: [], refundMethods: []);
}
