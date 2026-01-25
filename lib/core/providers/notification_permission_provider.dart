import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/notification_permission_constants.dart';

/// Provider for managing Android notification permission state
/// 
/// Handles:
/// - Permission status tracking
/// - Denial count management
/// - SharedPreferences persistence
/// - Lifecycle-aware permission checking
/// - Retry logic with cooldown
class NotificationPermissionProvider extends ChangeNotifier {
  /// Current permission status
  NotificationPermissionStatus _status = NotificationPermissionStatus.notDetermined;
  NotificationPermissionStatus get status => _status;

  /// Whether permission has been requested at least once
  bool _hasRequestedPermission = false;
  bool get hasRequestedPermission => _hasRequestedPermission;

  /// Number of times user has denied permission
  int _denialCount = 0;
  int get denialCount => _denialCount;

  /// Unix timestamp of last permission prompt
  int _lastPromptTime = 0;
  int get lastPromptTime => _lastPromptTime;

  /// Flag to prevent multiple simultaneous permission requests
  bool _isRequestingPermission = false;
  bool get isRequestingPermission => _isRequestingPermission;

  /// Session flag to prevent multiple prompts in same session
  bool _hasPromptedThisSession = false;
  bool get hasPromptedThisSession => _hasPromptedThisSession;

  /// Android SDK version (cached after first check)
  int? _androidSdkVersion;

  /// SharedPreferences instance
  SharedPreferences? _prefs;

  /// Whether the provider has been initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider with SharedPreferences
  /// Should be called once during app startup
  Future<void> initialize(SharedPreferences prefs) async {
    if (_isInitialized) return;

    _prefs = prefs;
    await _loadPersistedState();
    await _checkCurrentPermissionStatus();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load persisted state from SharedPreferences
  Future<void> _loadPersistedState() async {
    if (_prefs == null) return;

    _hasRequestedPermission = _prefs!.getBool(
      NotificationPermissionKeys.hasRequestedPermission,
    ) ?? false;

    _denialCount = _prefs!.getInt(
      NotificationPermissionKeys.denialCount,
    ) ?? 0;

    _lastPromptTime = _prefs!.getInt(
      NotificationPermissionKeys.lastPromptTime,
    ) ?? 0;

    final statusString = _prefs!.getString(
      NotificationPermissionKeys.permissionStatus,
    );
    _status = NotificationPermissionStatusExtension.fromStorageString(statusString);

    debugPrint('🔔 [NotificationPermission] Loaded state:');
    debugPrint('   hasRequestedPermission: $_hasRequestedPermission');
    debugPrint('   denialCount: $_denialCount');
    debugPrint('   status: $_status');
  }

  /// Save current state to SharedPreferences
  Future<void> _saveState() async {
    if (_prefs == null) return;

    await _prefs!.setBool(
      NotificationPermissionKeys.hasRequestedPermission,
      _hasRequestedPermission,
    );

    await _prefs!.setInt(
      NotificationPermissionKeys.denialCount,
      _denialCount,
    );

    await _prefs!.setInt(
      NotificationPermissionKeys.lastPromptTime,
      _lastPromptTime,
    );

    await _prefs!.setString(
      NotificationPermissionKeys.permissionStatus,
      _status.toStorageString(),
    );

    debugPrint('🔔 [NotificationPermission] State saved');
  }

  /// Get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    if (_androidSdkVersion != null) return _androidSdkVersion!;

    if (!Platform.isAndroid) {
      _androidSdkVersion = 0;
      return 0;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _androidSdkVersion = androidInfo.version.sdkInt;
      debugPrint('🔔 [NotificationPermission] Android SDK: $_androidSdkVersion');
      return _androidSdkVersion!;
    } catch (e) {
      debugPrint('🔔 [NotificationPermission] Error getting SDK version: $e');
      _androidSdkVersion = 33; // Assume latest if error
      return 33;
    }
  }

  /// Check current permission status from system
  /// Called on initialization and app resume
  Future<void> _checkCurrentPermissionStatus() async {
    if (!Platform.isAndroid) {
      _status = NotificationPermissionStatus.granted;
      return;
    }

    try {
      final sdkVersion = await _getAndroidSdkVersion();

      if (sdkVersion >= NotificationPermissionConfig.minSdkForRuntimePermission) {
        // Android 13+ - Use runtime permission
        final permissionStatus = await Permission.notification.status;
        _updateStatusFromPermission(permissionStatus);
      } else {
        // Android <13 - Notifications enabled by default
        // Check if user disabled in settings
        final permissionStatus = await Permission.notification.status;
        if (permissionStatus.isGranted) {
          _status = NotificationPermissionStatus.granted;
        } else {
          _status = NotificationPermissionStatus.denied;
        }
      }

      debugPrint('🔔 [NotificationPermission] Current status: $_status');
    } catch (e) {
      debugPrint('🔔 [NotificationPermission] Error checking status: $e');
      _status = NotificationPermissionStatus.notDetermined;
    }
  }

  /// Update internal status based on system permission status
  void _updateStatusFromPermission(PermissionStatus permissionStatus) {
    switch (permissionStatus) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        _status = NotificationPermissionStatus.granted;
        // Reset denial count on grant
        _denialCount = 0;
        break;
      case PermissionStatus.denied:
        if (_denialCount >= NotificationPermissionConfig.maxDenialCount) {
          _status = NotificationPermissionStatus.permanentlyDenied;
        } else {
          _status = NotificationPermissionStatus.denied;
        }
        break;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        _status = NotificationPermissionStatus.permanentlyDenied;
        break;
      case PermissionStatus.provisional:
        _status = NotificationPermissionStatus.granted;
        break;
    }
  }

  /// Check if we should show the initial permission prompt
  /// Returns true if:
  /// - On Android
  /// - Haven't prompted this session
  /// - Either never prompted, or retry is allowed
  bool shouldShowInitialPrompt() {
    if (!Platform.isAndroid) return false;
    if (_hasPromptedThisSession) return false;
    if (_status == NotificationPermissionStatus.granted) return false;
    if (_status == NotificationPermissionStatus.permanentlyDenied) return false;

    // Never prompted before
    if (!_hasRequestedPermission) return true;

    // Check if cooldown has passed for retry
    if (_denialCount < NotificationPermissionConfig.maxDenialCount) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - _lastPromptTime;
      if (elapsed >= NotificationPermissionConfig.promptCooldownMs) {
        return true;
      }
    }

    return false;
  }

  /// Request notification permission
  /// Returns the resulting permission status
  Future<NotificationPermissionStatus> requestPermission() async {
    if (!Platform.isAndroid) {
      return NotificationPermissionStatus.granted;
    }

    // Prevent concurrent requests
    if (_isRequestingPermission) {
      debugPrint('🔔 [NotificationPermission] Request already in progress');
      return _status;
    }

    _isRequestingPermission = true;
    _hasPromptedThisSession = true;
    notifyListeners();

    try {
      final sdkVersion = await _getAndroidSdkVersion();

      PermissionStatus result;

      if (sdkVersion >= NotificationPermissionConfig.minSdkForRuntimePermission) {
        // Android 13+ - Request runtime permission
        result = await Permission.notification.request();
      } else {
        // Android <13 - Check current status
        result = await Permission.notification.status;
      }

      debugPrint('🔔 [NotificationPermission] Permission result: $result');

      // Update state based on result
      if (result.isGranted) {
        _status = NotificationPermissionStatus.granted;
        _denialCount = 0;
        debugPrint('🔔 [NotificationPermission] Permission GRANTED');
      } else if (result.isPermanentlyDenied) {
        _status = NotificationPermissionStatus.permanentlyDenied;
        debugPrint('🔔 [NotificationPermission] Permission PERMANENTLY DENIED');
      } else {
        // User denied
        _denialCount++;
        _lastPromptTime = DateTime.now().millisecondsSinceEpoch;

        if (_denialCount >= NotificationPermissionConfig.maxDenialCount) {
          _status = NotificationPermissionStatus.permanentlyDenied;
          debugPrint('🔔 [NotificationPermission] Max denials reached - PERMANENTLY DENIED');
        } else {
          _status = NotificationPermissionStatus.denied;
          debugPrint('🔔 [NotificationPermission] Permission DENIED (count: $_denialCount)');
        }
      }

      // Mark as requested
      _hasRequestedPermission = true;

      // Persist state
      await _saveState();

      return _status;
    } catch (e) {
      debugPrint('🔔 [NotificationPermission] Error requesting permission: $e');
      return _status;
    } finally {
      _isRequestingPermission = false;
      notifyListeners();
    }
  }

  /// Open app settings for user to enable notifications
  Future<bool> openSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      final opened = await openAppSettings();
      debugPrint('🔔 [NotificationPermission] Opened app settings: $opened');
      return opened;
    } catch (e) {
      debugPrint('🔔 [NotificationPermission] Error opening settings: $e');
      return false;
    }
  }

  /// Called when app resumes from background
  /// Checks if permission status changed in settings
  Future<void> onAppResumed() async {
    if (!Platform.isAndroid) return;

    debugPrint('🔔 [NotificationPermission] App resumed - checking permission');

    final previousStatus = _status;
    await _checkCurrentPermissionStatus();

    if (_status != previousStatus) {
      debugPrint('🔔 [NotificationPermission] Status changed: $previousStatus -> $_status');

      // If user enabled in settings, reset denial count
      if (_status == NotificationPermissionStatus.granted) {
        _denialCount = 0;
      }

      await _saveState();
      notifyListeners();
    }
  }

  /// Check if retry is allowed based on denial count and cooldown
  bool canRetryPermission() {
    if (_status == NotificationPermissionStatus.granted) return false;
    if (_status == NotificationPermissionStatus.permanentlyDenied) return false;

    return _denialCount < NotificationPermissionConfig.maxDenialCount;
  }

  /// Get human-readable status for UI
  String getStatusDisplayText() {
    switch (_status) {
      case NotificationPermissionStatus.granted:
        return 'Enabled';
      case NotificationPermissionStatus.denied:
        return 'Enable';
      case NotificationPermissionStatus.permanentlyDenied:
        return 'Blocked';
      case NotificationPermissionStatus.notDetermined:
        return 'Enable';
    }
  }

  /// Reset session flag (call on app cold start)
  void resetSessionFlag() {
    _hasPromptedThisSession = false;
  }

  /// Force refresh permission status from system
  Future<void> refreshStatus() async {
    await _checkCurrentPermissionStatus();
    await _saveState();
    notifyListeners();
  }
}
