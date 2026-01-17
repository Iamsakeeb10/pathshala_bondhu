// lib/features/notifications/models/notification_model.dart

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    // PathShala Bondhu API response structure
    final notificationsData = json['notifications'];
    
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return NotificationResponse(
      notifications: (notificationsData['data'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      currentPage: parseInt(notificationsData['current_page']),
      lastPage: parseInt(notificationsData['last_page']),
      perPage: parseInt(notificationsData['per_page']),
      total: parseInt(notificationsData['total']),
      unreadCount: 0, // Will be fetched separately
    );
  }
}
