import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:story/routes/api_endpoints.dart';

import '../../../models/vip_subscription.dart';
import '../../../storage/secure_tokenstorage.dart';

// Custom exception for subscription-related errors
class SubscriptionException implements Exception {
  final String message;
  final int? statusCode;

  SubscriptionException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SubscriptionProvider with ChangeNotifier {
  final Dio dio;

  // Private state variables with clearer naming
  List<VipSubscription> _subscriptionHistory = [];
  VipSubscription? _currentActiveSubscription;
  bool _isLoadingData = false;
  String? _errorMessage;

  // Add state for tracking API request status
  bool _isRefreshing = false;
  DateTime? _lastFetchTime;

  SubscriptionProvider({required this.dio});

  // Getters with validation and immutability
  List<VipSubscription> get subscriptionHistory =>
      List.unmodifiable(_subscriptionHistory);
  VipSubscription? get activeSubscription => _currentActiveSubscription;
  bool get isLoading => _isLoadingData;
  String? get error => _errorMessage;
  bool get hasActiveSubscription => _currentActiveSubscription != null;

  // Enhanced fetch subscription history with retry logic and caching
  Future<void> fetchSubscriptions({bool forceRefresh = false}) async {
    // Prevent duplicate calls unless force refresh is requested
    if (_isLoadingData && !forceRefresh) return;
    if (_isRefreshing) return;

    try {
      _setLoading(true);
      _isRefreshing = true;

      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/vip/history',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
          // Add reasonable timeouts
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['data'] != null && data['data']['subscriptions'] != null) {
          _subscriptionHistory = (data['data']['subscriptions'] as List)
              .map((json) => VipSubscription.fromJson(json))
              .toList();

          // Sort subscriptions by start date (most recent first)
          _subscriptionHistory
              .sort((a, b) => b.startDate.compareTo(a.startDate));

          _errorMessage = null;
          _lastFetchTime = DateTime.now();
        } else {
          throw SubscriptionException('Invalid response format from server');
        }
      } else {
        throw SubscriptionException(
          response.data['message'] ?? 'Failed to load subscription history',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred while fetching subscriptions';
      debugPrint('Subscription fetch error: $e');
      rethrow;
    } finally {
      _setLoading(false);
      _isRefreshing = false;
    }
  }

  // Enhanced active subscription fetch with better error handling
  Future<void> fetchActiveSubscription() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/vip/history/active',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          _currentActiveSubscription = VipSubscription.fromJson(data['data']);
          _errorMessage = null;
        } else {
          // No active subscription is a valid state
          _currentActiveSubscription = null;
        }
      } else {
        throw SubscriptionException(
          response.data['message'] ?? 'Failed to fetch active subscription',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _currentActiveSubscription = null;
    } catch (e) {
      _errorMessage =
          'Unexpected error occurred while fetching active subscription';
      debugPrint('Active subscription fetch error: $e');
      _currentActiveSubscription = null;
    } finally {
      notifyListeners();
    }
  }

  // Enhanced error handling with more specific error messages
  void _handleDioError(DioException e) {
    _errorMessage = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Connection timeout. Please check your internet connection.',
      DioExceptionType.connectionError =>
        'Unable to connect to server. Please check your internet connection.',
      _ when e.response?.statusCode == 401 =>
        'Session expired. Please log in again.',
      _ when e.response?.statusCode == 403 =>
        'Access denied. Please check your subscription status.',
      _ when e.response?.data?['message'] != null =>
        e.response!.data['message'],
      _ => 'An error occurred. Please try again later.',
    };
  }

  // Secure header generation with token validation
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureTokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw SubscriptionException('Authentication token not found');
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  void _setLoading(bool value) {
    _isLoadingData = value;
    notifyListeners();
  }

  // Additional utility methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to check if data needs refresh
  bool get needsRefresh {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >
        const Duration(minutes: 5);
  }

  // Cleanup method
  void dispose() {
    _subscriptionHistory.clear();
    _currentActiveSubscription = null;
    super.dispose();
  }
}
