import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../storage/storage_service.dart';
import 'app_exception.dart';

/// Thin Dio wrapper: base URL + auth header + logging (debug only) +
/// error mapping to [AppException]. Every repository goes through this.
class ApiClient extends GetxService {
  static const baseUrl = 'https://callfororders.in';
  static const apiPrefix = '/api/customer';

  late final Dio dio;

  /// Called by the auth interceptor whenever a request comes back 401,
  /// so the app can force-logout without ApiClient depending on AuthController.
  void Function()? onUnauthorized;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl$apiPrefix',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final cartToken = await StorageService.instance.readCartToken();
          if (cartToken != null && cartToken.isNotEmpty && token != null) {
            // Hand a guest basket over on the first authenticated call.
            options.headers['X-Cart-Token'] = cartToken;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _guard(() => dio.get(path, queryParameters: _clean(query)));

  Future<Response<dynamic>> post(String path, {dynamic data}) =>
      _guard(() => dio.post(path, data: data));

  Future<Response<dynamic>> put(String path, {dynamic data}) =>
      _guard(() => dio.put(path, data: data));

  Future<Response<dynamic>> patch(String path, {dynamic data}) =>
      _guard(() => dio.patch(path, data: data));

  Future<Response<dynamic>> delete(String path, {dynamic data}) =>
      _guard(() => dio.delete(path, data: data));

  Map<String, dynamic>? _clean(Map<String, dynamic>? q) {
    if (q == null) return null;
    final out = <String, dynamic>{};
    q.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }

  Future<Response<dynamic>> _guard(
    Future<Response<dynamic>> Function() run,
  ) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(
        message: 'No internet connection. Please try again.',
        type: AppExceptionType.network,
      );
    }
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String message = 'Something went wrong. Please try again.';
    Map<String, List<String>>? fieldErrors;
    if (body is Map) {
      if (body['message'] is String) message = body['message'];
      final errors = body['errors'];
      if (errors is Map) {
        fieldErrors = errors.map(
          (k, v) => MapEntry(
            k.toString(),
            (v as List).map((e) => e.toString()).toList(),
          ),
        );
        if (fieldErrors.isNotEmpty && (body['message'] == null)) {
          message = fieldErrors.values.first.first;
        }
      }
    }
    switch (status) {
      case 401:
        message = body is Map && body['message'] is String
            ? body['message']
            : 'Please sign in to continue.';
        break;
      case 403:
        message = body is Map && body['message'] is String
            ? body['message']
            : 'You are not allowed to do that.';
        break;
      case 404:
        message = body is Map && body['message'] is String
            ? body['message']
            : 'Not found.';
        break;
      case 429:
        message = 'Too many attempts. Please wait a moment and try again.';
        break;
    }
    return AppException.fromStatus(status, message, errors: fieldErrors);
  }
}
