import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:uuid/uuid.dart';

class MaterialRequestRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Box<MaterialRequestModel> _materialRequestBox;

  MaterialRequestRepository(
    this._apiClient,
    this._networkInfo,
    this._materialRequestBox,
  );

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

  // Get my material requests (with offline support)
  Future<List<MaterialRequestModel>> getMyRequests() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get('${ApiConstants.materialRequests}/my');
        
        final List<dynamic> data = response.data['data'] ?? response.data;
        final requests = data.map((json) => MaterialRequestModel.fromJson(json)).toList();
        
        // Cache online requests
        for (var request in requests) {
          final existing = _materialRequestBox.values.firstWhere(
            (r) => r.id == request.id,
            orElse: () => MaterialRequestModel(
              id: 0,
              projectId: 0,
              requestedBy: 0,
              status: '',
              createdAt: '',
              updatedAt: '',
            ),
          );
          
          if (existing.id == 0) {
            await _materialRequestBox.add(request);
          }
        }
        
        return requests;
      } catch (e) {
        AppLogger.error('Failed to fetch my material requests', e);
        // Fall back to local cache
        return _materialRequestBox.values.toList();
      }
    } else {
      // Offline: return cached data
      AppLogger.info('Offline: returning cached material requests');
      return _materialRequestBox.values.toList();
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

  // Create material request (with offline support)
  Future<MaterialRequestModel> createRequest({
    required int projectId,
    String? description,
    required List<Map<String, dynamic>> items,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.post(
          ApiConstants.materialRequests,
          data: {
            'project_id': projectId,
            'description': description,
            'items': items,
          },
        );
        
        final request = MaterialRequestModel.fromJson(response.data['data'] ?? response.data);
        
        // Save to local cache
        await _materialRequestBox.add(request);
        
        return request;
      } catch (e) {
        AppLogger.error('Failed to create material request online', e);
        rethrow;
      }
    } else {
      // Offline: save locally
      final localId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();
      
      final offlineRequest = MaterialRequestModel(
        id: 0, // Will be assigned by server
        projectId: projectId,
        requestedBy: 0, // Will be set from auth context
        status: 'pending',
        description: description,
        createdAt: now,
        updatedAt: now,
        items: items.map((item) => MaterialRequestItemModel(
          id: 0,
          materialRequestId: 0,
          materialId: item['material_id'] as int,
          quantity: item['quantity'] as int,
          materialName: item['material_name']?.toString(),
          unit: item['unit']?.toString(),
        )).toList(),
        isSynced: false,
        localId: localId,
      );
      
      await _materialRequestBox.add(offlineRequest);
      
      AppLogger.info('Material request saved offline with ID: $localId');
      
      return offlineRequest;
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

  // Receive material request (mark as physically received and add to stock)
  Future<void> receiveRequest(int requestId, Map<int, int> receivedItems) async {
    try {
      final jsonReceivedItems = <String, dynamic>{};
      receivedItems.forEach((itemId, qty) {
        jsonReceivedItems[itemId.toString()] = qty;
      });

      await _apiClient.post(
        '${ApiConstants.materialRequests}/$requestId/receive',
        data: {'items': jsonReceivedItems},
      );
      AppLogger.info('Material request marked as received');
    } catch (e) {
      AppLogger.error('Failed to receive material request', e);
      rethrow;
    }
  }

  // Sync pending material requests
  Future<void> syncPendingRequests() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (!isOnline) {
      AppLogger.info('Cannot sync material requests: offline');
      return;
    }

    final unsyncedRequests = _materialRequestBox.values
        .where((request) => !request.isSynced && request.localId != null)
        .toList();

    if (unsyncedRequests.isEmpty) {
      AppLogger.info('No pending material requests to sync');
      return;
    }

    AppLogger.info('Syncing ${unsyncedRequests.length} pending material requests');

    for (var request in unsyncedRequests) {
      try {
        final response = await _apiClient.post(
          ApiConstants.materialRequests,
          data: {
            'project_id': request.projectId,
            'description': request.description,
            'items': request.items.map((item) => {
              'material_id': item.materialId,
              'quantity': item.quantity,
            }).toList(),
          },
        );

        final syncedRequest = MaterialRequestModel.fromJson(
          response.data['data'] ?? response.data,
        );

        // Update local record with server data
        await request.delete();
        await _materialRequestBox.add(syncedRequest);

        AppLogger.info('Material request synced: ${request.localId} -> ${syncedRequest.id}');
      } catch (e) {
        AppLogger.error('Failed to sync material request: ${request.localId}', e);
        // Continue with next request
      }
    }
  }
}
