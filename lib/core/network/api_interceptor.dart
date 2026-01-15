import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/root_navigator_key.dart';
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
      debugPrint('🔒 Unauthorized! Force logout initiated.');
      await _handleForceLogout();
    }

    // Handle 403 Forbidden
    if (statusCode == 403) {
      debugPrint('🚫 Forbidden! Access denied.');
      await _handleForceLogout();
    }

    super.onError(err, handler);
  }

  /// Handle force logout on auth errors
  Future<void> _handleForceLogout() async {
    // Clear all stored data
    await TokenStorage.clearAll();

    // Navigate to login screen
    // Using rootNavigatorKey from app_router.dart
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      // Import go_router for navigation
      context.go('/login');
      debugPrint('🔓 Redirected to login screen');
    }
  }
}
