import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/order.dart';
import '../models/paginated.dart';

class OrdersRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Order numbers come back from the API as "#1043". A bare '#' in a URL
  /// path is a fragment separator, not path text — `GET /orders/#1043`
  /// silently truncates to `GET /orders/`, hitting the *list* endpoint
  /// instead of the detail one. The docs confirm the API accepts the number
  /// with or without the '#', so we always strip it before building a path.
  String _clean(String number) => number.startsWith('#') ? number.substring(1) : number;

  Future<Paginated<Order>> list({String filter = 'all', int page = 1}) async {
    final res = await _api.get('/orders', query: {'filter': filter, 'page': page});
    return Paginated.fromJson(Map<String, dynamic>.from(res.data), Order.fromJson);
  }

  Future<Order> detail(String number) async {
    final res = await _api.get('/orders/${_clean(number)}');
    return Order.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<OrderTrack> track(String number) async {
    final res = await _api.get('/orders/${_clean(number)}/track');
    return OrderTrack.fromJson(Map<String, dynamic>.from(res.data['data'] ?? res.data));
  }

  Future<ReorderResult> reorder(String number) async {
    final res = await _api.post('/orders/${_clean(number)}/reorder');
    return ReorderResult.fromJson(Map<String, dynamic>.from(res.data['data'] ?? res.data));
  }

  Future<String> invoiceUrl(String number) async {
    final res = await _api.get('/orders/${_clean(number)}/invoice');
    final data = Map<String, dynamic>.from(res.data['data'] ?? res.data);
    return '${data['url'] ?? ''}';
  }
}
