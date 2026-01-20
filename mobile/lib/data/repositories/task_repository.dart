import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/task_model.dart';

class TaskRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Box<TaskModel> _taskBox;
  
  TaskRepository(
    this._apiClient,
    this._networkInfo,
    this._taskBox,
  );
  
  Future<List<TaskModel>> getMyTasks() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get(ApiConstants.myTasks);
        final List<dynamic> data = response.data['data'];
        final tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        
        // Update local cache
        for (var task in tasks) {
          await _taskBox.put(task.id, task);
        }
        
        return tasks;
      } catch (e) {
        AppLogger.error('Failed to fetch tasks', e);
      }
    }
    
    // Return from local storage
    return _taskBox.values.toList();
  }
  
  Future<TaskModel> updateTaskStatus(int taskId, String status) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.put(
          '${ApiConstants.tasks}/$taskId',
          data: {'status': status},
        );
        
        final task = TaskModel.fromJson(response.data['data']);
        await _taskBox.put(task.id, task);
        return task;
      } on DioException catch (e) {
        AppLogger.error('Failed to update task status', e);
        throw Exception(e.response?.data['message'] ?? 'Update failed');
      }
    } else {
      // Offline mode
      final task = _taskBox.get(taskId);
      if (task != null) {
        final updated = task.copyWith(status: status, isSynced: false);
        await _taskBox.put(taskId, updated);
        AppLogger.info('Task status updated offline');
        return updated;
      }
      throw Exception('Task not found');
    }
  }
  
  Future<void> syncPendingTasks() async {
    final unsyncedTasks = _taskBox.values.where((t) => !t.isSynced).toList();
    
    for (var task in unsyncedTasks) {
      try {
        await _apiClient.put(
          '${ApiConstants.tasks}/${task.id}',
          data: {'status': task.status},
        );
        
        final updated = task.copyWith(isSynced: true);
        await _taskBox.put(task.id, updated);
        AppLogger.info('Synced task: ${task.id}');
      } catch (e) {
        AppLogger.error('Failed to sync task', e);
      }
    }
  }
}
