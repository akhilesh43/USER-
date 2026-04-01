import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum UserState { initial, loading, success, error, empty }

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = []; // All matching search
  List<UserModel> _displayedUsers = []; // Matches for current pagination
  
  UserState _state = UserState.initial;
  String _errorMessage = '';
  
  // Search and Pagination states
  String _searchQuery = '';
  Timer? _debounce;
  int _currentPage = 0;
  final int _batchSize = 5;
  bool _hasMore = true;

  UserState get state => _state;
  String get errorMessage => _errorMessage;
  List<UserModel> get users => _displayedUsers;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  UserProvider() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _state = UserState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _allUsers = await _apiService.fetchUsers();
      if (_allUsers.isEmpty) {
        _state = UserState.empty;
      } else {
        _state = UserState.success;
        _applySearchAndPagination(resetSearch: false);
      }
    } catch (e) {
      _state = UserState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void retry() {
    fetchUsers();
  }

  void searchUsers(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      _applySearchAndPagination(resetSearch: true);
      notifyListeners();
    });
  }

  void loadMore() {
    if (!_hasMore || _state == UserState.loading) return;
    
    _currentPage++;
    _updateDisplayedUsers();
    notifyListeners();
  }

  void _applySearchAndPagination({required bool resetSearch}) {
    if (resetSearch) {
      _currentPage = 0;
      _displayedUsers.clear();
    }
    
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(q);
      }).toList();
    }
    
    _hasMore = _filteredUsers.length > (_currentPage + 1) * _batchSize;
    
    if (_filteredUsers.isEmpty) {
      _state = UserState.empty;
      _displayedUsers = [];
    } else {
      _state = UserState.success;
      _updateDisplayedUsers();
    }
  }

  void _updateDisplayedUsers() {
    int start = 0;
    int end = (_currentPage + 1) * _batchSize;
    if (end > _filteredUsers.length) {
      end = _filteredUsers.length;
      _hasMore = false;
    }
    _displayedUsers = _filteredUsers.sublist(start, end);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
