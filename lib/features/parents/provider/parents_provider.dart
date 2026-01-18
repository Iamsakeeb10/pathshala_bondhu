import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../teachers/data/models/teacher_model.dart';
import '../data/models/parent_model.dart';
import '../data/services/parents_service.dart';

/// Provider for parents list feature with pagination and debounced search
class ParentsProvider extends ChangeNotifier {
  final ParentsService _service;

  List<ParentListModel> _parents = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Debounce timer for search
  Timer? _debounceTimer;

  // Cancel token for API requests
  CancelToken? _cancelToken;

  ParentsProvider() : _service = ParentsService();

  // Getters
  List<ParentListModel> get parents => _parents;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasData => _parents.isNotEmpty;
  bool get isEmpty => !_isLoading && _parents.isEmpty && _errorMessage == null;
  bool get hasMore => _pagination?.hasMore ?? false;

  /// Fetch parents list with optional search
  ///
  /// [refresh] - If true, fetches from page 1 and clears existing data
  /// [search] - Optional search query
  Future<void> fetchParents({bool refresh = false, String? search}) async {
    if (_isLoading || _isLoadingMore) return;

    // Use provided search or current search query
    final searchTerm = search ?? _searchQuery;
    final page = refresh ? 1 : (_pagination?.currentPage ?? 0) + 1;

    if (refresh) {
      _isLoading = true;
      _errorMessage = null;
      _parents.clear();
    } else {
      // Check if we have more pages before loading more
      if (_pagination != null && !_pagination!.hasMore) return;
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _service.getParents(
        page: page,
        perPage: 10,
        search: searchTerm.isNotEmpty ? searchTerm : null,
      );

      if (refresh) {
        _parents = response.parents;
      } else {
        _parents.addAll(response.parents);
      }

      _pagination = response.pagination;
      _isLoading = false;
      _isLoadingMore = false;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isLoadingMore = false;
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Search parents with debounce (400ms delay)
  ///
  /// This method is called on each keystroke in the search field.
  /// It debounces the API call to avoid excessive requests.
  void searchParents(String query) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Update search query immediately for UI
    _searchQuery = query;

    // Show searching indicator
    _isSearching = true;
    notifyListeners();

    // Debounce the API call (400ms)
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      // Cancel any pending API request
      _cancelToken?.cancel();
      _cancelToken = CancelToken();

      // Fetch with new search query
      fetchParents(refresh: true, search: query);
    });
  }

  /// Clear search and reload full list
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    fetchParents(refresh: true, search: '');
  }

  /// Load more parents (pagination)
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore) return;
    await fetchParents(refresh: false);
  }

  /// Retry after error
  Future<void> retry() async {
    await fetchParents(refresh: true);
  }

  /// Reset provider state (call on logout)
  void reset() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    _parents = [];
    _pagination = null;
    _isLoading = false;
    _isLoadingMore = false;
    _isSearching = false;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }
}
