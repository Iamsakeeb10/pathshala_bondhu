import 'package:flutter/material.dart';

import '../data/models/books_models.dart';
import '../data/services/books_service.dart';

/// Provider for books feature
/// Implements in-memory caching
/// Cache is cleared on student change or logout
class BooksProvider extends ChangeNotifier {
  final BooksService _booksService;

  BookListResponse? _cachedData;
  bool _isLoading = false;
  String? _errorMessage;

  BooksProvider() : _booksService = BooksService();

  // Getters
  BookListResponse? get data => _cachedData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _cachedData != null;
  bool get isEmpty => _cachedData != null && _cachedData!.childrenBookLists.isEmpty;

  /// Fetch book list
  /// Uses cache if available
  Future<void> fetchBookList({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (_cachedData != null && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cachedData = await _booksService.getBookList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear cache
  /// Call this when student selection changes or on logout
  void clearCache() {
    _cachedData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading
  Future<void> retry() async {
    await fetchBookList(forceRefresh: true);
  }
}
