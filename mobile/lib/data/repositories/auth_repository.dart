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
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'phone': phone},
      );
      
      final token = response.data['data']['token'];
      final user = UserModel.fromJson(response.data['data']['user']);
      
      // Save token and user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, user.toJson().toString());
      
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
      await _apiClient.post(ApiConstants.logout);
      AppLogger.info('Logout request completed successfully');
    } catch (e) {
      AppLogger.warning('Logout API call failed: $e');
    } finally {
      await _clearLocalData();
      AppLogger.info('Logged out successfully - local data cleared');
    }
  }

  Future<void> _clearLocalData() async {
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear typed Hive boxes that are opened in the app lifecycle
    try {
      if (Hive.isBoxOpen(AppConstants.attendanceBox)) {
        await Hive.box<dynamic>(AppConstants.attendanceBox).clear();
      }
      if (Hive.isBoxOpen(AppConstants.taskBox)) {
        await Hive.box<dynamic>(AppConstants.taskBox).clear();
      }
      if (Hive.isBoxOpen(AppConstants.dprBox)) {
        await Hive.box<dynamic>(AppConstants.dprBox).clear();
      }
      if (Hive.isBoxOpen(AppConstants.materialRequestBox)) {
        await Hive.box<dynamic>(AppConstants.materialRequestBox).clear();
      }
      if (Hive.isBoxOpen(AppConstants.syncQueueBox)) {
        await Hive.box<dynamic>(AppConstants.syncQueueBox).clear();
      }
    } catch (e) {
      AppLogger.warning('Error clearing Hive boxes', e);
    }
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      AppLogger.error('Failed to get current user', e);
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
