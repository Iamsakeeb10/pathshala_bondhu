// ============================================================================
// 5. lib/core/network/connectivity_interceptor.dart
// ============================================================================
import 'package:dio/dio.dart';

import '../services/connectivity_service.dart';

class ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check connectivity before making request
    final isConnected = await _connectivityService.checkConnectivity();

    if (!isConnected) {
      // Reject request with custom error
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: NoInternetException(),
          message: 'No internet connection',
        ),
      );
      return;
    }

    // Continue with request if connected
    handler.next(options);
  }
}

/// Custom exception for no internet
class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}
