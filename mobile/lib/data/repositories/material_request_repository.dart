import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/material_request_model.dart';

class MaterialRequestRepository {
  final ApiClient _apiClient;

  MaterialRequestRepository(this._apiClient);

  // Get all material requests
  Future<List<MaterialRequestModel>> getAllRequests() async {
    try {
      final response = await _apiClient.get(ApiConstants.materialRequests);
      
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MaterialRequestModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch material requests', e);
      rethrow;
    }
  }

  // Get my material requests
  Future<List<MaterialRequestModel>> getMyRequests() async {
    try {
      final response = await _apiClient.get('${ApiConstants.materialRequests}/my');
      
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MaterialRequestModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch my material requests', e);
      rethrow;
    }
  }

  // Get pending material requests (for approval)
  Future<List<MaterialRequestModel>> getPendingRequests() async {
    try {
      final response = await _apiClient.get('${ApiConstants.materialRequests}/pending');
      
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MaterialRequestModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch pending material requests', e);
      rethrow;
    }
  }

  // Create material request
  Future<MaterialRequestModel> createRequest({
    required int projectId,
    String? description,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.materialRequests,
        data: {
          'project_id': projectId,
          'description': description,
          'items': items,
        },
      );
      
      return MaterialRequestModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      AppLogger.error('Failed to create material request', e);
      rethrow;
    }
  }

  // Approve material request
  Future<void> approveRequest(int requestId) async {
    try {
      await _apiClient.post('${ApiConstants.materialRequests}/$requestId/approve');
    } catch (e) {
      AppLogger.error('Failed to approve material request', e);
      rethrow;
    }
  }

  // Reject material request
  Future<void> rejectRequest(int requestId) async {
    try {
      await _apiClient.post('${ApiConstants.materialRequests}/$requestId/reject');
    } catch (e) {
      AppLogger.error('Failed to reject material request', e);
      rethrow;
    }
  }

  // Get all materials
  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final response = await _apiClient.get(ApiConstants.materials);
      
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch materials', e);
      rethrow;
    }
  }

  // Update material request status (for managers to approve/reject with allocated quantities)
  Future<void> updateRequestStatus(
    int requestId,
    String status,
    String? remarks, {
    Map<int, int>? allocatedItems,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'status': status,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      // Convert allocated_items map to JSON-encodable format
      if (allocatedItems != null && allocatedItems.isNotEmpty) {
        final jsonAllocatedItems = <String, dynamic>{};
        allocatedItems.forEach((itemId, qty) {
          jsonAllocatedItems[itemId.toString()] = qty;
        });
        requestData['allocated_items'] = jsonAllocatedItems;
      }

      await _apiClient.patch(
        '${ApiConstants.materialRequests}/$requestId/status',
        data: requestData,
      );
      AppLogger.info('Material request status updated to $status');
    } catch (e) {
      AppLogger.error('Failed to update material request status', e);
      rethrow;
    }
  }
}
