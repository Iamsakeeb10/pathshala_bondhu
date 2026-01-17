// lib/features/notifications/providers/notification_provider.dart

import 'package:flutter/material.dart';

import '../data/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoadingMore = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _currentPage < _lastPage;

  NotificationProvider() {
    _loadCachedUnreadCount();
  }

  // Load cached unread count on init
  Future<void> _loadCachedUnreadCount() async {
    try {
      _unreadCount = await _repository.getCachedUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached count: $e');
    }
  }

  // Fetch unread count (for badge)
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      await _repository.cacheUnreadCount(_unreadCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  // Fetch notifications
  Future<void> fetchNotifications({
    bool refresh = false,
    String? type,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
    }

    if (_isLoading || _isLoadingMore) return;

    if (refresh) {
      _isLoading = true;
      _hasError = false;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _repository.getNotifications(
        page: _currentPage,
        perPage: 20,
        type: type,
      );

      if (refresh) {
        _notifications = response.notifications;
      } else {
        _notifications.addAll(response.notifications);
      }

      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _total = response.total;
      _hasError = false;

      // Fetch unread count separately
      await fetchUnreadCount();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMore({String? type}) async {
    if (!hasMorePages || _isLoadingMore) return;

    _currentPage++;
    await fetchNotifications(type: type);
  }

  // Mark all notifications as read when viewing (Facebook behavior)
  Future<void> markAllAsReadOnView() async {
    // Only mark if there are unread notifications
    if (_unreadCount == 0) return;

    try {
      // Call API to mark all as read
      await _repository.markAllAsRead();

      // Update local state - mark all notifications as read
      _notifications = _notifications.map((notification) {
        return NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      // Reset unread count
      _unreadCount = 0;
      await _repository.cacheUnreadCount(_unreadCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read on view: $e');
      // Don't show error to user - this is a background operation
    }
  }

  // Mark all notifications as read (manual action)
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((notification) {
        return NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      _unreadCount = 0;
      await _repository.cacheUnreadCount(_unreadCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      rethrow;
    }
  }

  // Mark single notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final updatedNotification = await _repository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = updatedNotification;

        // Decrease unread count if notification was unread
        if (!_notifications[index].isRead && _unreadCount > 0) {
          _unreadCount--;
          await _repository.cacheUnreadCount(_unreadCount);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Reset state
  void reset() {
    _notifications = [];
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    _isLoadingMore = false;
    notifyListeners();
  }
}
