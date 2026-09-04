// ignore_for_file: use_null_aware_elements

import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/address.dart';
import '../models/app_content.dart';
import '../models/customer.dart';
import '../models/paginated.dart';
import '../models/product.dart';
import '../models/review.dart';

class AccountRepository {
  final ApiClient _api = Get.find<ApiClient>();

  // --- Profile -------------------------------------------------------
  Future<Customer> me() async {
    final res = await _api.get('/me');
    final body = Map<String, dynamic>.from(res.data);
    return Customer.fromJson(Map<String, dynamic>.from(body['data'] ?? body));
  }

  Future<Customer> updateMe(Map<String, dynamic> fields) async {
    final res = await _api.put('/me', data: fields);
    final body = Map<String, dynamic>.from(res.data);
    return Customer.fromJson(Map<String, dynamic>.from(body['data'] ?? body));
  }

  Future<AccountSummary> summary() async {
    final res = await _api.get('/me/summary');
    return AccountSummary.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<void> deleteMe() => _api.delete('/me');

  Future<void> changePassword({
    String? currentPassword,
    required String password,
    required String passwordConfirmation,
  }) => _api.put(
    '/me/password',
    data: {
      if (currentPassword != null) 'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    },
  );

  // --- Addresses -------------------------------------------------------
  Future<List<Address>> addresses() async {
    final res = await _api.get('/addresses');
    return (res.data['data'] as List)
        .map((e) => Address.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Address> createAddress(Map<String, dynamic> body) async {
    final res = await _api.post('/addresses', data: body);
    return Address.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<Address> updateAddress(int id, Map<String, dynamic> body) async {
    final res = await _api.put('/addresses/$id', data: body);
    return Address.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<void> deleteAddress(int id) => _api.delete('/addresses/$id');

  Future<void> setDefaultAddress(int id) =>
      _api.patch('/addresses/$id/default');

  // --- Wishlist -------------------------------------------------------
  Future<List<ProductCardModel>> wishlist() async {
    final res = await _api.get('/wishlist');
    return (res.data['data'] as List)
        .map((e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> addToWishlist(int productId) =>
      _api.post('/wishlist', data: {'product_id': productId});

  Future<void> removeFromWishlist(int productId) =>
      _api.delete('/wishlist/$productId');

  // --- Reviews -------------------------------------------------------
  Future<Map<String, dynamic>> myReviews() async {
    final res = await _api.get('/reviews');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Review> writeReview(
    int productId, {
    required int rating,
    String? title,
    String? body,
  }) async {
    final res = await _api.post(
      '/products/$productId/reviews',
      data: {
        'rating': rating,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      },
    );
    return Review.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<void> deleteReview(int reviewId) => _api.delete('/reviews/$reviewId');

  // --- Wallet / payment methods -----------------------------------------
  Future<WalletSummary> wallet() async {
    final res = await _api.get('/wallet');
    return WalletSummary.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<List<SavedPaymentMethod>> paymentMethods() async {
    final res = await _api.get('/payment-methods');
    return (res.data['data'] as List? ?? res.data as List? ?? [])
        .map((e) => SavedPaymentMethod.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SavedPaymentMethod> addPaymentMethod({
    required String type,
    required String label,
    required String maskedValue,
    String? gatewayToken,
  }) async {
    final res = await _api.post(
      '/payment-methods',
      data: {
        'type': type,
        'label': label,
        'masked_value': maskedValue,
        if (gatewayToken != null) 'gateway_token': gatewayToken,
      },
    );
    return SavedPaymentMethod.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<void> deletePaymentMethod(int id) =>
      _api.delete('/payment-methods/$id');

  Future<void> setDefaultPaymentMethod(int id) =>
      _api.patch('/payment-methods/$id/default');

  // --- Notifications ---------------------------------------------------
  Future<Paginated<dynamic>> notifications({int page = 1}) async {
    final res = await _api.get('/notifications', query: {'page': page});
    return Paginated.fromJson(Map<String, dynamic>.from(res.data), (j) => j);
  }

  Future<int> unreadCount() async {
    final res = await _api.get('/notifications/unread-count');
    final body = Map<String, dynamic>.from(res.data);
    return (body['unread_count'] ?? body['count'] ?? 0) as int;
  }

  Future<void> markRead(int id) => _api.post('/notifications/$id/read');

  Future<void> markAllRead() => _api.post('/notifications/read-all');

  Future<void> deleteNotification(int id) => _api.delete('/notifications/$id');

  // --- Push devices ------------------------------------------------------
  Future<void> registerPushDevice({
    required String token,
    required String platform,
    String? deviceName,
  }) => _api.post(
    '/push/device',
    data: {
      'token': token,
      'platform': platform,
      if (deviceName != null) 'device_name': deviceName,
    },
  );

  Future<void> unregisterPushDevice(String token) =>
      _api.delete('/push/device', data: {'token': token});

  Future<NotificationPreferences> notificationPreferences() async {
    final res = await _api.get('/notification-preferences');
    return NotificationPreferences.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences prefs,
  ) async {
    final res = await _api.put('/notification-preferences', data: prefs.toJson());
    return NotificationPreferences.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<SupportConfig> supportConfig() async {
    final res = await _api.get('/support/config');
    return SupportConfig.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  Future<List<LegalPageRef>> legalPages() async {
    final res = await _api.get('/legal');
    return (res.data['data'] as List? ?? res.data as List? ?? [])
        .map((e) => LegalPageRef.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> legalPage(String slug) async {
    final res = await _api.get('/legal/$slug');
    return Map<String, dynamic>.from(res.data['data'] ?? res.data);
  }

  Future<AppConfig> appConfig() async {
    final res = await _api.get('/app-config');
    return AppConfig.fromJson(
      Map<String, dynamic>.from(res.data['data'] ?? res.data),
    );
  }

  // --- Signed-in devices ---------------------------------------------
  Future<List<dynamic>> devices() async {
    final res = await _api.get('/auth/devices');
    return (res.data['data'] ?? res.data) as List;
  }

  Future<void> revokeDevice(String tokenId) =>
      _api.delete('/auth/devices/$tokenId');
}
