import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/network/api_client.dart';
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
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      AppLogger.warning('Logout API call failed', e);
    } finally {
      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      AppLogger.info('Logged out successfully');
    }
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
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
