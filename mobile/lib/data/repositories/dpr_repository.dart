import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:uuid/uuid.dart';

class DprRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Box<DprModel> _dprBox;
  final Box<ProjectModel> _projectBox;
  
  DprRepository(
    this._apiClient,
    this._networkInfo,
    this._dprBox,
    this._projectBox,
  );
  
  Future<DprModel> submitDpr({
    required int projectId,
    required String workDescription,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
    List<int>? taskIds, // Changed to list
    int? taskId, // Keep for backward compatibility
    double? billingAmount,
    double? gstPercentage,
  }) async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final isOnline = await _networkInfo.isConnected;
    
    // Handle backward compatibility - convert single taskId to list
    final effectiveTaskIds = taskIds ?? (taskId != null ? [taskId] : <int>[]);
    
    if (isOnline) {
      try {
        // Create FormData for multipart upload
        final formData = FormData.fromMap({
          'project_id': projectId,
          'work_description': workDescription,
          'report_date': date,
          'latitude': latitude,
          'longitude': longitude,
          'billing_amount': billingAmount,
          'gst_percentage': gstPercentage,
        });
        
        // Add task IDs as array
        if (effectiveTaskIds.isNotEmpty) {
          for (int i = 0; i < effectiveTaskIds.length; i++) {
            formData.fields.add(MapEntry('task_ids[$i]', effectiveTaskIds[i].toString()));
          }
        }
        
        // Add photos as multipart files
        for (int i = 0; i < photoPaths.length; i++) {
          formData.files.add(
            MapEntry(
              'photos[$i]',
              await MultipartFile.fromFile(
                photoPaths[i],
                filename: 'dpr_photo_$i.jpg',
              ),
            ),
          );
        }
        
        final response = await _apiClient.postFormData(ApiConstants.dprs, formData);
        final dpr = DprModel.fromJson(response.data['data']);
        
        await _dprBox.put(dpr.id, dpr);
        AppLogger.info('DPR submitted successfully');
        return dpr;
      } on DioException catch (e) {
        AppLogger.error('DPR submission failed', e);
        throw Exception(e.response?.data['message'] ?? 'Submission failed');
      }
    } else {
      // Offline mode
      final localId = const Uuid().v4();
      final dpr = DprModel(
        projectId: projectId,
        userId: 0, // Will be filled during sync
        workDescription: workDescription,
        reportDate: date,
        latitude: latitude,
        longitude: longitude,
        status: 'draft',
        localPhotoPaths: photoPaths,
        isSynced: false,
        localId: localId,
        taskId: effectiveTaskIds.isNotEmpty ? effectiveTaskIds.first : null, // Store first task for offline
        billingAmount: billingAmount,
        gstPercentage: gstPercentage,
      );
      
      await _dprBox.put(localId, dpr);
      AppLogger.info('DPR saved offline');
      return dpr;
    }
  }
  
  Future<List<DprModel>> getMyDprs({int page = 1}) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get(
          ApiConstants.myDprs,
          queryParameters: {'page': page},
        );
        
        // API may return paginated {data: {data: [...]}} or plain list []
        final dynamic raw = response.data['data'];
        List<dynamic> data;
        if (raw is List) {
          data = raw;
        } else if (raw is Map && raw['data'] is List) {
          data = raw['data'] as List;
        } else {
          data = [];
        }

        final dprs = data.map((json) => DprModel.fromJson(json)).toList();
        
        // Update local cache
        for (var dpr in dprs) {
          await _dprBox.put(dpr.id, dpr);
        }
        
        return dprs;
      } catch (e) {
        AppLogger.error('Failed to fetch DPRs', e);
      }
    }
    
    // Return from local storage
    return _dprBox.values.toList()
      ..sort((a, b) => b.reportDate.compareTo(a.reportDate));
  }
  
  Future<List<DprModel>> getPendingDprs() async {
    try {
      final response = await _apiClient.get(ApiConstants.dprsPending);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DprModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch pending DPRs', e);
      return [];
    }
  }
  
  Future<void> approveDpr(int dprId, String status) async {
    try {
      await _apiClient.post(
        ApiConstants.dprApprove.replaceAll('{id}', dprId.toString()),
        data: {'status': status},
      );
      AppLogger.info('DPR $status');
    } on DioException catch (e) {
      AppLogger.error('DPR approval failed', e);
      throw Exception(e.response?.data['message'] ?? 'Approval failed');
    }
  }
  
  Future<void> rejectDpr(int dprId, String remarks) async {
    try {
      await _apiClient.post(
        ApiConstants.dprApprove.replaceAll('{id}', dprId.toString()),
        data: {
          'status': 'rejected',
          'remarks': remarks,
        },
      );
      AppLogger.info('DPR rejected');
    } on DioException catch (e) {
      AppLogger.error('DPR rejection failed', e);
      throw Exception(e.response?.data['message'] ?? 'Rejection failed');
    }
  }
  
  Future<void> syncPendingDprs() async {
    final unsyncedDprs = _dprBox.values.where((d) => !d.isSynced).toList();
    
    for (var dpr in unsyncedDprs) {
      try {
        final formData = FormData.fromMap({
          'project_id': dpr.projectId,
          'work_description': dpr.workDescription,
          'report_date': dpr.reportDate,
          'latitude': dpr.latitude,
          'longitude': dpr.longitude,
          'billing_amount': dpr.billingAmount,
          'gst_percentage': dpr.gstPercentage,
        });
        
        // Add local photos
        for (int i = 0; i < dpr.localPhotoPaths.length; i++) {
          final file = File(dpr.localPhotoPaths[i]);
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'photos[$i]',
                await MultipartFile.fromFile(
                  dpr.localPhotoPaths[i],
                  filename: 'dpr_photo_$i.jpg',
                ),
              ),
            );
          }
        }
        
        final response = await _apiClient.postFormData(ApiConstants.dprs, formData);
        final synced = DprModel.fromJson(response.data['data']);
        
        await _dprBox.delete(dpr.localId);
        await _dprBox.put(synced.id, synced);
        AppLogger.info('Synced DPR: ${dpr.localId}');
      } catch (e) {
        AppLogger.error('Failed to sync DPR', e);
      }
    }
  }
  
  // Get user's projects
  Future<List<ProjectModel>> getUserProjects() async {
    try {
      final response = await _apiClient.get(ApiConstants.projects);
      final List<dynamic> data = response.data['data'] ?? response.data;
      final projects = data.map((json) => ProjectModel.fromJson(json)).toList();
      
      // Cache projects for offline use
      await _projectBox.clear();
      for (var project in projects) {
        await _projectBox.put(project.id, project);
      }
      AppLogger.info('Projects cached: ${projects.length}');
      
      return projects;
    } catch (e) {
      AppLogger.warning('Failed to fetch user projects from API, loading from cache', e);
      
      // Load from cache when offline
      final cachedProjects = _projectBox.values.toList();
      AppLogger.info('Loaded ${cachedProjects.length} projects from cache');
      
      return cachedProjects;
    }
  }

  // Get users for a specific project
  Future<List<dynamic>> getProjectUsers(int projectId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.projects}/$projectId/users');
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch project users', e);
      rethrow;
    }
  }

  // Update DPR status (for managers to approve/reject)
  Future<void> updateDprStatus(int dprId, String status, String? remarks) async {
    try {
      await _apiClient.patch(
        '${ApiConstants.dprs}/$dprId/status',
        data: {
          'status': status,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        },
      );
      AppLogger.info('DPR status updated to $status');
    } catch (e) {
      AppLogger.error('Failed to update DPR status', e);
      rethrow;
    }
  }
}
