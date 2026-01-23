import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  UserRepository(
    this._apiClient,
    this._networkInfo,
  );

  Future<List<UserModel>> getAllUsers() async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching users');
      return [];
    }

    try {
      final response = await _apiClient.get(ApiConstants.users);

      final List<dynamic> data = response.data['data'] ?? [];
      final users = data.map((json) => UserModel.fromJson(json)).toList();

      return users;
    } catch (e) {
      AppLogger.error('Failed to fetch users', e);
      rethrow;
    }
  }

  Future<UserModel?> getUserById(int id) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching user');
      return null;
    }

    try {
      final response = await _apiClient.get('${ApiConstants.users}/$id');

      final user = UserModel.fromJson(response.data['data']);
      return user;
    } catch (e) {
      AppLogger.error('Failed to fetch user', e);
      rethrow;
    }
  }

  Future<UserModel> createUser({
    required String name,
    required String phone,
    required String email,
    required String role,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.users,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'role': role,
        },
      );

      final user = UserModel.fromJson(response.data['data']);
      return user;
    } catch (e) {
      AppLogger.error('Failed to create user', e);
      rethrow;
    }
  }

  Future<UserModel> updateUser(
    int id, {
    String? name,
    String? phone,
    String? email,
    String? role,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (role != null) data['role'] = role;

      final response = await _apiClient.put(
        '${ApiConstants.users}/$id',
        data: data,
      );

      final user = UserModel.fromJson(response.data['data']);
      return user;
    } catch (e) {
      AppLogger.error('Failed to update user', e);
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      await _apiClient.delete('${ApiConstants.users}/$id');
    } catch (e) {
      AppLogger.error('Failed to delete user', e);
      rethrow;
    }
  }
}
