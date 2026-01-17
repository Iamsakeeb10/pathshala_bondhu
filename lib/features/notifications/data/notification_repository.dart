// lib/features/notifications/data/notification_repository.dart

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final DioClient _dioClient = DioClient();

  // Get paginated notifications
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null && type.isNotEmpty) 'type': type,
      };

      final response = await _dioClient.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      return NotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.notificationsUnreadCount);
      return response.data['unread_count'] ?? 0;
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }

  // Mark single notification as read
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final endpoint = ApiEndpoints.markNotificationRead.replaceFirst(
        '{id}',
        '$notificationId',
      );

      final response = await _dioClient.post(endpoint);

      return NotificationModel.fromJson(response.data['notification']);
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dioClient.post(ApiEndpoints.markAllNotificationsRead);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  // Cache unread count
  Future<void> cacheUnreadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_notification_count', count);
  }

  // Get cached unread count
  Future<int> getCachedUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unread_notification_count') ?? 0;
  }
}
