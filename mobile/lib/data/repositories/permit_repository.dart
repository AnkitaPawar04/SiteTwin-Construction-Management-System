import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/providers.dart';

final permitRepositoryProvider = Provider<PermitRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PermitRepository(apiClient);
});

class PermitRepository {
  final ApiClient _apiClient;

  PermitRepository(this._apiClient);

  /// Request a new permit (Supervisor only)
  Future<Map<String, dynamic>> requestPermit({
    required int projectId,
    required String taskType,
    required String description,
    required String safetyMeasures,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/permits/request',
        data: {
          'project_id': projectId,
          'task_type': taskType,
          'description': description,
          'safety_measures': safetyMeasures,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to submit permit request');
    }
  }

  /// Get all permits (role-filtered on backend)
  Future<List<Map<String, dynamic>>> getPermits() async {
    try {
      final response = await _apiClient.get('${ApiConstants.baseUrl}/permits');
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      throw Exception('Failed to load permits');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to load permits');
    }
  }

  /// Get single permit details
  Future<Map<String, dynamic>> getPermit(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.baseUrl}/permits/$id');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Failed to load permit');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to load permit');
    }
  }

  /// Approve permit (Safety Officer only)
  Future<Map<String, dynamic>> approvePermit(int id) async {
    try {
      final response = await _apiClient.post('${ApiConstants.baseUrl}/permits/$id/approve');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to approve permit');
    }
  }

  /// Reject permit (Safety Officer only)
  Future<Map<String, dynamic>> rejectPermit(int id, String reason) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/permits/$id/reject',
        data: {'rejection_reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to reject permit');
    }
  }

  /// Verify OTP and start work (Supervisor only)
  Future<Map<String, dynamic>> verifyOTP(int id, String otp) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/permits/$id/verify-otp',
        data: {'otp': otp},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to verify OTP');
    }
  }

  /// Complete work (Supervisor only)
  Future<Map<String, dynamic>> completeWork(int id) async {
    try {
      final response = await _apiClient.post('${ApiConstants.baseUrl}/permits/$id/complete');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to complete work');
    }
  }

  /// Get permit statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiClient.get('${ApiConstants.baseUrl}/permits/stats/summary');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Failed to load statistics');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Failed to load statistics');
    }
  }
}
