import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/customer.dart';

class AuthResult {
  final String token;
  final Customer customer;
  AuthResult({required this.token, required this.customer});
}

class AuthRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Returns the debug OTP code when the API is not in production.
  Future<String?> requestOtp(String phone) async {
    final res = await _api.post('/auth/otp', data: {'phone': phone});
    return res.data['debug_code']?.toString();
  }

  Future<AuthResult> verifyOtp({
    required String phone,
    required String code,
    required String deviceName,
    String? firstName,
  }) async {
    final res = await _api.post('/auth/otp/verify', data: {
      'phone': phone,
      'code': code,
      'device_name': deviceName,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
    });
    return AuthResult(token: res.data['token'], customer: Customer.fromJson(res.data['customer']));
  }

  Future<AuthResult> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String deviceName,
  }) async {
    final res = await _api.post('/auth/register', data: {
      'first_name': firstName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': deviceName,
    });
    return AuthResult(token: res.data['token'], customer: Customer.fromJson(res.data['customer']));
  }

  Future<AuthResult> login({required String email, required String password, required String deviceName}) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });
    return AuthResult(token: res.data['token'], customer: Customer.fromJson(res.data['customer']));
  }

  Future<void> forgotPassword(String email) => _api.post('/auth/forgot-password', data: {'email': email});

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      _api.post('/auth/reset-password', data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

  Future<void> logout() => _api.post('/auth/logout');

  Future<void> logoutAll() => _api.post('/auth/logout-all');

  Future<void> refresh() => _api.post('/auth/refresh');
}
