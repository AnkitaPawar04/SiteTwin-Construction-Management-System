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
  
  DprRepository(
    this._apiClient,
    this._networkInfo,
    this._dprBox,
  );
  
  Future<DprModel> submitDpr({
    required int projectId,
    required String workDescription,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
  }) async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        // Create FormData for multipart upload
        final formData = FormData.fromMap({
          'project_id': projectId,
          'work_description': workDescription,
          'report_date': date,
          'latitude': latitude,
          'longitude': longitude,
        });
        
        // Add photos
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
        
        final List<dynamic> data = response.data['data']['data'];
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
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch user projects', e);
      rethrow;
    }
  }
}
