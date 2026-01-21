import 'package:mobile/data/models/notification_model.dart';
import 'package:mobile/core/network/api_client.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await _apiClient.get('/notifications');
    final data = response.data['data'] as List;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await _apiClient.get('/notifications/unread');
    final data = response.data['data'] as List;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.post('/notifications/read-all');
  }
}
