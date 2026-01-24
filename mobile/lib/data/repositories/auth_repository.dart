import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_error.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepository(this._apiClient);
  
  Future<Map<String, dynamic>> login(String phone) async {
    try {
      // Clear any previous session data before logging in
      AppLogger.info('Clearing previous session before login');
      await _clearLocalData();
      
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'phone': phone},
      );
      
      final token = response.data['data']['token'];
      final user = UserModel.fromJson(response.data['data']['user']);
      
      // Save token and user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
      
      AppLogger.info('Login successful for ${user.name}');
      
      return {
        'token': token,
        'user': user,
      };
    } on DioException catch (e) {
      AppLogger.error('Login failed', e);
      throw ApiError.fromDio(e);
    }
  }
  
  Future<void> logout() async {
    try {
      AppLogger.info('Sending logout request to ${ApiConstants.logout}');
      await _apiClient.post(ApiConstants.logout).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.warning('Logout API request timed out');
          throw Exception('Logout request timed out');
        },
      );
      AppLogger.info('Logout request completed successfully');
    } catch (e) {
      AppLogger.warning('Logout API call failed: $e');
      // Continue with local cleanup even if API call fails
    } finally {
      await _clearLocalData();
      AppLogger.info('Logged out successfully - local data cleared');
    }
  }

  Future<void> _clearLocalData() async {
    AppLogger.info('Clearing all local data...');
    
    // Clear shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      for (var key in keys) {
        await prefs.remove(key);
      }
      AppLogger.info('Cleared ${keys.length} SharedPreferences keys');
    } catch (e) {
      AppLogger.warning('Error clearing SharedPreferences', e);
    }

    // Clear typed Hive boxes that are opened in the app lifecycle
    try {
      final boxesToClear = [
        AppConstants.attendanceBox,
        AppConstants.taskBox,
        AppConstants.dprBox,
        AppConstants.materialRequestBox,
        AppConstants.syncQueueBox,
      ];
      
      for (var boxName in boxesToClear) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box<dynamic>(boxName);
          await box.clear();
          AppLogger.info('Cleared Hive box: $boxName');
        }
      }
    } catch (e) {
      AppLogger.warning('Error clearing Hive boxes', e);
    }
    
    AppLogger.info('Local data cleared successfully');
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      final user = UserModel.fromJson(response.data['data']);
      
      // Update local cache when online
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
      
      return user;
    } on DioException catch (e) {
      AppLogger.warning('Failed to get current user from API, trying local cache', e);
      
      // Try to load from local storage when offline
      try {
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(AppConstants.userKey);
        
        if (userJson != null && userJson.isNotEmpty) {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          final user = UserModel.fromJson(userMap);
          AppLogger.info('User loaded from local cache (offline mode): ${user.name}');
          return user;
        }
      } catch (localError) {
        AppLogger.error('Failed to load user from local cache', localError);
      }
      
      return null;
    }
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
