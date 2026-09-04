// ignore_for_file: use_null_aware_elements

import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/paginated.dart';
import '../models/request_item.dart';

class RequestsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// See OrdersRepository._clean — a literal '#' truncates the URL at that
  /// point, so it must be stripped before building any /orders/{number} path.
  String _clean(String number) =>
      number.startsWith('#') ? number.substring(1) : number;

  Future<void> cancelOrder(
    String orderNumber, {
    String? reason,
    String? note,
    List<Map<String, dynamic>>? items,
  }) => _api.post(
    '/orders/${_clean(orderNumber)}/cancellations',
    data: {
      if (reason != null) 'reason': reason,
      if (note != null) 'note': note,
      if (items != null) 'items': items,
    },
  );

  Future<void> returnOrder(
    String orderNumber, {
    required String reason,
    required String method,
    String? note,
    required List<Map<String, dynamic>> items,
  }) => _api.post(
    '/orders/${_clean(orderNumber)}/returns',
    data: {
      'reason': reason,
      'method': method,
      if (note != null) 'note': note,
      'items': items,
    },
  );

  Future<Paginated<RequestItem>> list({int page = 1}) async {
    final res = await _api.get('/requests', query: {'page': page});
    return Paginated.fromJson(
      Map<String, dynamic>.from(res.data),
      RequestItem.fromJson,
    );
  }

  Future<RequestItem> detail(String number) async {
    final res = await _api.get('/requests/$number');
    return RequestItem.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<void> withdraw(String number) =>
      _api.post('/requests/$number/withdraw');
}
