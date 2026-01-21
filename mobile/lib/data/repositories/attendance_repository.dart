import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:uuid/uuid.dart';

class AttendanceRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Box<AttendanceModel> _attendanceBox;
  
  AttendanceRepository(
    this._apiClient,
    this._networkInfo,
    this._attendanceBox,
  );
  
  Future<AttendanceModel> checkIn({
    required int projectId,
    required double latitude,
    required double longitude,
  }) async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final checkIn = DateTime.now().toIso8601String();
    
    // Check if already checked in today (from local storage)
    final todayAttendance = _attendanceBox.values.firstWhere(
      (a) => a.date == date,
      orElse: () => AttendanceModel(
        userId: 0,
        projectId: 0,
        date: '',
        latitude: 0,
        longitude: 0,
      ),
    );
    
    if (todayAttendance.date == date) {
      throw Exception('Already checked in today');
    }
    
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.post(
          ApiConstants.attendanceCheckIn,
          data: {
            'project_id': projectId,
            'latitude': latitude,
            'longitude': longitude,
          },
        );
        
        final attendance = AttendanceModel.fromJson(response.data['data']);
        await _attendanceBox.put(attendance.id, attendance);
        return attendance;
      } on DioException catch (e) {
        AppLogger.error('Check-in failed', e);
        // Extract validation errors if available
        final errors = e.response?.data['errors'];
        final message = e.response?.data['message'] ?? 'Check-in failed';
        if (errors != null) {
          final errorMessages = (errors as Map).values.map((e) => e.toString()).join(', ');
          throw Exception('$message: $errorMessages');
        }
        throw Exception(message);
      }
    } else {
      // Offline mode
      final localId = const Uuid().v4();
      final attendance = AttendanceModel(
        userId: 0, // Will be filled during sync
        projectId: projectId,
        date: date,
        checkIn: checkIn,
        latitude: latitude,
        longitude: longitude,
        isSynced: false,
        localId: localId,
      );
      
      await _attendanceBox.put(localId, attendance);
      AppLogger.info('Check-in saved offline');
      return attendance;
    }
  }
  
  Future<AttendanceModel> checkOut({
    required int attendanceId,
    required double latitude,
    required double longitude,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.post(
          ApiConstants.attendanceCheckOut,
          data: {
            'latitude': latitude,
            'longitude': longitude,
          },
        );
        
        final attendance = AttendanceModel.fromJson(response.data['data']);
        await _attendanceBox.put(attendance.id, attendance);
        return attendance;
      } on DioException catch (e) {
        AppLogger.error('Check-out failed', e);
        throw Exception(e.response?.data['message'] ?? 'Check-out failed');
      }
    } else {
      // Offline mode
      final localAttendance = _attendanceBox.get(attendanceId);
      if (localAttendance != null) {
        final updated = AttendanceModel(
          id: localAttendance.id,
          userId: localAttendance.userId,
          projectId: localAttendance.projectId,
          date: localAttendance.date,
          checkIn: localAttendance.checkIn,
          checkOut: DateTime.now().toIso8601String(),
          latitude: latitude,
          longitude: longitude,
          isSynced: false,
          localId: localAttendance.localId,
        );
        
        await _attendanceBox.put(attendanceId, updated);
        AppLogger.info('Check-out saved offline');
        return updated;
      }
      throw Exception('Attendance record not found');
    }
  }
  
  Future<List<AttendanceModel>> getMyAttendance({int page = 1}) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get(
          ApiConstants.myAttendance,
          queryParameters: {'page': page},
        );
        
        final List<dynamic> data = response.data['data']['data'];
        final attendances = data.map((json) => AttendanceModel.fromJson(json)).toList();
        
        // Update local cache - only if id is not null
        for (var attendance in attendances) {
          if (attendance.id != null) {
            await _attendanceBox.put(attendance.id!, attendance);
          }
        }
        
        return attendances;
      } catch (e) {
        AppLogger.error('Failed to fetch attendance', e);
      }
    }
    
    // Return from local storage
    return _attendanceBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  Future<AttendanceModel?> getTodayAttendance() async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    
    // Try from local storage first
    final localAttendance = _attendanceBox.values
        .where((a) => a.date == date)
        .firstOrNull;
    
    if (localAttendance != null) {
      return localAttendance;
    }
    
    // Fetch from API if online
    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      final attendances = await getMyAttendance();
      return attendances.where((a) => a.date == date).firstOrNull;
    }
    
    return null;
  }
  
  Future<void> syncPendingAttendance() async {
    final unsyncedAttendance = _attendanceBox.values
        .where((a) => !a.isSynced)
        .toList();
    
    for (var attendance in unsyncedAttendance) {
      try {
        if (attendance.checkOut == null) {
          // Sync check-in
          final response = await _apiClient.post(
            ApiConstants.attendanceCheckIn,
            data: attendance.toJson(),
          );
          final synced = AttendanceModel.fromJson(response.data['data']);
          await _attendanceBox.delete(attendance.localId);
          await _attendanceBox.put(synced.id, synced);
        } else {
          // Sync check-out
          final response = await _apiClient.post(
            ApiConstants.attendanceCheckOut,
            data: {
              'latitude': attendance.latitude,
              'longitude': attendance.longitude,
            },
          );
          final synced = AttendanceModel.fromJson(response.data['data']);
          await _attendanceBox.put(synced.id, synced);
        }
        AppLogger.info('Synced attendance: ${attendance.localId}');
      } catch (e) {
        AppLogger.error('Failed to sync attendance', e);
      }
    }
  }

  /// Get team attendance summary for a project (for managers)
  Future<Map<String, dynamic>> getTeamAttendanceSummary(int projectId, {String? date}) async {
    try {
      final queryDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await _apiClient.get(
        '/attendance/project/$projectId/team-summary?date=$queryDate',
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch team attendance summary', e);
      rethrow;
    }
  }

  /// Get attendance trends for a project
  Future<Map<String, dynamic>> getAttendanceTrends(int projectId, {int days = 30}) async {
    try {
      final response = await _apiClient.get(
        '/attendance/project/$projectId/trends?days=$days',
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch attendance trends', e);
      rethrow;
    }
  }
}
