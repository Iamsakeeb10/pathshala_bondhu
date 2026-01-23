// lib/core/services/notification_service.dart

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router/root_navigator_key.dart';
import '../../core/network/token_storage.dart';
import '../../features/chat/providers/conversations_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Make sure Firebase is initialized
  await Firebase.initializeApp();

  print('🔔 Background handler called for: ${message.messageId}');

  // Firebase already shows the notification in background/terminated state
  // We don't need to show it again here
}

/// Notification callback data model
class NotificationPayload {
  final String? route;
  final Map<String, dynamic>? data;

  NotificationPayload({this.route, this.data});

  factory NotificationPayload.fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = map['data'] != null
          ? Map<String, dynamic>.from(map['data'])
          : <String, dynamic>{};
      return NotificationPayload(route: map['route'] as String?, data: data);
    } catch (e) {
      return NotificationPayload(route: null, data: <String, dynamic>{});
    }
  }

  String toJson() {
    return jsonEncode({'route': route, 'data': data});
  }
}

/// Notification types enum
enum NotificationType {
  general,
  feePayment,
  attendance,
  result,
  announcement,
  reminder,
  system,
}

/// Channel configuration
class NotificationChannelConfig {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final Priority priority;
  final bool playSound;
  final bool enableVibration;
  final String? sound;

  const NotificationChannelConfig({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.high,
    this.priority = Priority.high,
    this.playSound = true,
    this.enableVibration = true,
    this.sound,
  });
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for handling notification taps
  static Function(NotificationPayload)? _onNotificationTap;

  // Track shown notification IDs to prevent duplicates
  static final Set<String> _shownNotificationIds = {};

  // Track app start state
  static bool isColdStart = true;
  static bool isNotificationLaunch = false;

  static String? pendingRoute;
  static bool isAppReady = false;

  static Future<void> consumePendingRoute(BuildContext context) async {
    isAppReady = true;

    final contextToUse = rootNavigatorKey.currentContext ?? context;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!contextToUse.mounted) return;

      if (pendingRoute != null) {
        GoRouter.of(contextToUse).go('/dashboard');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (contextToUse.mounted) {
            GoRouter.of(contextToUse).push(pendingRoute!);
            pendingRoute = null;
          }
        });
      }
    });

    // Reset cold start flag after consumption attempt
    isColdStart = false;
  }

  /// Predefined notification channels
  static const Map<NotificationType, NotificationChannelConfig> _channels = {
    NotificationType.general: NotificationChannelConfig(
      id: 'general_channel',
      name: 'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    NotificationType.feePayment: NotificationChannelConfig(
      id: 'fee_payment_channel',
      name: 'Fee Payment',
      description: 'Fee payment notifications and reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    NotificationType.attendance: NotificationChannelConfig(
      id: 'attendance_channel',
      name: 'Attendance',
      description: 'Attendance notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
    NotificationType.result: NotificationChannelConfig(
      id: 'result_channel',
      name: 'Results',
      description: 'Exam results and grades',
      importance: Importance.high,
      priority: Priority.high,
    ),
    NotificationType.announcement: NotificationChannelConfig(
      id: 'announcement_channel',
      name: 'Announcements',
      description: 'School announcements',
      importance: Importance.high,
      priority: Priority.high,
    ),
    NotificationType.reminder: NotificationChannelConfig(
      id: 'reminder_channel',
      name: 'Reminders',
      description: 'School reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    NotificationType.system: NotificationChannelConfig(
      id: 'system_channel',
      name: 'System Notifications',
      description: 'App updates and system messages',
      importance: Importance.low,
      priority: Priority.low,
    ),
  };

  /// Initialize notifications with callback
  static Future<void> init({
    Function(NotificationPayload)? onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create all notification channels
    await _createNotificationChannels();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened from background/terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check for initial notification (when app opened from terminated state)
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        isNotificationLaunch = true;
        _handleNotificationOpen(initialMessage);
      }
    } catch (e) {
      print('⚠️ Failed to get initial message: $e');
    }

    // Log FCM token
    final token = await getDeviceToken();
    print('🔑 FCM Token: $token');
  }

  /// Request notification permission
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('✅ Notification permission: ${settings.authorizationStatus}');
  }

  /// Create all notification channels
  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    for (var entry in _channels.entries) {
      final config = entry.value;
      final channel = AndroidNotificationChannel(
        config.id,
        config.name,
        description: config.description,
        importance: config.importance,
        playSound: config.playSound,
        enableVibration: config.enableVibration,
        sound: config.sound != null
            ? RawResourceAndroidNotificationSound(config.sound!)
            : null,
      );

      await androidPlugin.createNotificationChannel(channel);
      print('📢 Created channel: ${config.name}');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground message received');
    print('   Message ID: ${message.messageId}');
    print('   Data: ${message.data}');

    if (message.notification == null && message.data.isEmpty) return;

    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final uniqueId = '${message.messageId}_${title}_$body';

    if (_shownNotificationIds.contains(uniqueId)) {
      print('⚠️ Duplicate notification detected: $uniqueId');
      return;
    }

    _shownNotificationIds.add(uniqueId);
    Future.delayed(const Duration(seconds: 10), () {
      _shownNotificationIds.remove(uniqueId);
    });

    await _showNotificationFromRemote(message);

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.read<NotificationProvider>().fetchUnreadCount();

      final notifType = message.data['type'] as String?;

      // ✅ Refresh conversations for new message (Realtime Sync)
      if (notifType == 'new_message') {
        try {
          final conversationsProvider = context.read<ConversationsProvider>();
          final userIdStr = await TokenStorage.getUserId();
          final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
          if (userId != null) {
            print('💬 Syncing conversations for new message (Foreground)...');
            conversationsProvider.fetchConversations(userId);
          }
        } catch (e) {
          print('⚠️ Error syncing conversations in foreground: $e');
        }
      }
    }
  }

  /// Handle notification opened (background / terminated)
  static void _handleNotificationOpen(RemoteMessage message) {
    print('🔔 Notification opened from background/terminated');
    print('   Message ID: ${message.messageId}');
    print('   Data: ${message.data}');

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      // Fetch updated unread count
      context.read<NotificationProvider>().fetchUnreadCount();

      final notifType = message.data['type'] as String?;

      // ✅ Refresh conversations for new message (Realtime Sync)
      if (notifType == 'new_message') {
        try {
          final conversationsProvider = context.read<ConversationsProvider>();
          TokenStorage.getUserId().then((userIdStr) {
            final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
            if (userId != null) {
              print('💬 Syncing conversations for new message (Background/Terminated)...');
              conversationsProvider.fetchConversations(userId);
            }
          });
        } catch (e) {
          print('⚠️ Error syncing conversations in background: $e');
        }
      }
    }

    final route = message.data['route'] as String?;
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    data.remove('route');

    final payload = NotificationPayload(route: route, data: data);
    _onNotificationTap?.call(payload);
  }

  /// Handle local notification tap
  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final payload = NotificationPayload.fromJson(response.payload!);
      print('🔔 Local notification tapped: ${payload.toJson()}');
      _onNotificationTap?.call(payload);
    }
  }

  /// Display notification from remote (only for foreground)
  static Future<void> _showNotificationFromRemote(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    final route = message.data['route'] as String?;
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    data.remove('route');

    final payload = NotificationPayload(route: route, data: data);

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    // Generate consistent ID from messageId
    final notificationId =
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload.toJson(),
    );

    print('✅ Notification displayed: $title');
  }

  /// Send local notification with specific type
  static Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? route,
    Map<String, dynamic>? data,
    int? id,
  }) async {
    final config = _channels[type]!;

    final androidDetails = AndroidNotificationDetails(
      config.id,
      config.name,
      channelDescription: config.description,
      importance: config.importance,
      priority: config.priority,
      playSound: config.playSound,
      enableVibration: config.enableVibration,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: null,
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: false,
        htmlFormatContent: false,
        htmlFormatTitle: false,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = NotificationPayload(route: route, data: data);

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: payload.toJson(),
    );
  }

  /// Cancel a notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get device FCM token
  static Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('⚠️ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('📡 Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('📡 Unsubscribed from topic: $topic');
  }

  /// Update FCM token on server
  static Future<void> updateTokenOnServer(
    Future<void> Function(String token) updateFunction,
  ) async {
    final token = await getDeviceToken();
    if (token != null) {
      print('🟩 [Token] Sending initial token to backend...');
      await updateFunction(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      print('🔄 Token refreshed: $newToken');
      await updateFunction(newToken);
      print('✅ [Token] Updated on backend successfully.');
    });
  }

  /// Get pending notifications count
  static Future<int> getPendingNotificationCount() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    return pending.length;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
