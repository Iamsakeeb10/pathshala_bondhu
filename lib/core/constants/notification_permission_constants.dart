/// Constants for notification permission management
/// Used across the app for consistent permission handling

/// SharedPreferences keys for notification permission state
class NotificationPermissionKeys {
  NotificationPermissionKeys._();

  /// Whether the user has been prompted for notification permission
  static const String hasRequestedPermission =
      'notification_has_requested_permission';

  /// Number of times the user has denied notification permission
  static const String denialCount = 'notification_denial_count';

  /// Unix timestamp of the last permission prompt
  static const String lastPromptTime = 'notification_last_prompt_time';

  /// Current permission status string
  static const String permissionStatus = 'notification_permission_status';
}

/// Enum representing the current notification permission status
enum NotificationPermissionStatus {
  /// User has granted notification permission
  granted,

  /// User denied permission but can still retry (denial count < 2)
  denied,

  /// User denied ≥2 times or blocked in system settings
  permanentlyDenied,

  /// Permission has never been requested (Android <13 fallback)
  notDetermined,
}

/// Extension to convert enum to/from string for persistence
extension NotificationPermissionStatusExtension
    on NotificationPermissionStatus {
  /// Convert status to string for SharedPreferences storage
  String toStorageString() {
    switch (this) {
      case NotificationPermissionStatus.granted:
        return 'granted';
      case NotificationPermissionStatus.denied:
        return 'denied';
      case NotificationPermissionStatus.permanentlyDenied:
        return 'permanentlyDenied';
      case NotificationPermissionStatus.notDetermined:
        return 'notDetermined';
    }
  }

  /// Create status from stored string
  static NotificationPermissionStatus fromStorageString(String? value) {
    switch (value) {
      case 'granted':
        return NotificationPermissionStatus.granted;
      case 'denied':
        return NotificationPermissionStatus.denied;
      case 'permanentlyDenied':
        return NotificationPermissionStatus.permanentlyDenied;
      case 'notDetermined':
      default:
        return NotificationPermissionStatus.notDetermined;
    }
  }
}

/// Configuration constants for permission retry logic
class NotificationPermissionConfig {
  NotificationPermissionConfig._();

  /// Maximum number of denials before permanently blocking
  static const int maxDenialCount = 2;

  /// Cooldown period between permission prompts (24 hours in milliseconds)
  static const int promptCooldownMs = 24 * 60 * 60 * 1000;

  /// Minimum Android SDK version requiring runtime notification permission
  static const int minSdkForRuntimePermission = 33;
}
