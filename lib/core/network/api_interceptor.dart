// ============================================================================
// 6. lib/core/network/api_interceptor.dart
// ============================================================================
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'token_storage.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Bearer token if available
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Pretty logging
    debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
    debugPrint('📦 Headers: ${options.headers}');
    if (options.data != null) debugPrint('📤 Body: ${options.data}');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Pretty logging
    debugPrint(
      '✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('📥 Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Log error
    debugPrint(
      '❌ [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    debugPrint('⚠️ Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('📝 Data: ${err.response?.data}');
    }

    final statusCode = err.response?.statusCode;

    // Handle 401 Unauthorized - Token expired or invalid
    if (statusCode == 401) {
      debugPrint('🔒 Unauthorized! Token might be expired.');
      await TokenStorage.clearToken();

      // TODO: Redirect to login page
      // You can implement navigation logic here when needed
      // Example:
      // navigatorKey.currentContext?.pushReplacementNamed('/login');
    }

    // Handle 403 Forbidden
    if (statusCode == 403) {
      debugPrint('🚫 Forbidden! Access denied.');
      // TODO: Handle forbidden access
    }

    super.onError(err, handler);
  }
}
