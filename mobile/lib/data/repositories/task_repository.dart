import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_error.dart';
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

  Future<List<TaskModel>> getAllTasks() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get(ApiConstants.tasks);
        final List<dynamic> data = response.data['data'];
        final tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        
        // Update local cache
        for (var task in tasks) {
          await _taskBox.put(task.id, task);
        }
        
        return tasks;
      } catch (e) {
        AppLogger.error('Failed to fetch all tasks', e);
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
        throw ApiError.fromDio(e);
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

  // Create and assign task (for managers)
  Future<TaskModel> createTask({
    required int projectId,
    required String title,
    required String description,
    required double billingAmount,
    required double gstPercentage,
    int? assignedTo,
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tasks,
        data: {
          'project_id': projectId,
          'title': title,
          'description': description,
          'billing_amount': billingAmount,
          'gst_percentage': gstPercentage,
          if (assignedTo != null) 'assigned_to': assignedTo,
          'priority': priority,
          if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
          'status': 'pending',
        },
      );
      
      final task = TaskModel.fromJson(response.data['data']);
      await _taskBox.put(task.id, task);
      AppLogger.info('Task created and assigned successfully');
      return task;
    } catch (e) {
      AppLogger.error('Failed to create task', e);
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _apiClient.delete('${ApiConstants.tasks}/$taskId');
      await _taskBox.delete(taskId);
      AppLogger.info('Task deleted successfully');
    } catch (e) {
      AppLogger.error('Failed to delete task', e);
      rethrow;
    }
  }

  Future<TaskModel> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? status,
    int? assignedTo,
    String? priority,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status;
      if (assignedTo != null) data['assigned_to'] = assignedTo;
      if (priority != null) data['priority'] = priority;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String().split('T')[0];

      final response = await _apiClient.put(
        '${ApiConstants.tasks}/$taskId',
        data: data,
      );
      
      final task = TaskModel.fromJson(response.data['data']);
      await _taskBox.put(task.id, task);
      AppLogger.info('Task updated successfully');
      return task;
    } catch (e) {
      AppLogger.error('Failed to update task', e);
      rethrow;
    }
  }
}
