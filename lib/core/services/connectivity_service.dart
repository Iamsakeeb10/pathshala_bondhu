// ============================================================================
// 4. lib/core/services/connectivity_service.dart
// ============================================================================
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream to listen for connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> init() async {
    // Check initial connectivity
    _isConnected = await checkConnectivity();

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      final hasConnection = await checkConnectivity();
      if (hasConnection != _isConnected) {
        _isConnected = hasConnection;
        _connectivityController.add(_isConnected);

        if (_isConnected) {
          debugPrint('✅ Internet connection restored');
        } else {
          debugPrint('❌ Internet connection lost');
        }
      }
    });
  }

  /// Check if device has internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Check if any connection type is available (wifi, mobile, ethernet)
      return result.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet,
      );
    } catch (e) {
      debugPrint('⚠️ Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
