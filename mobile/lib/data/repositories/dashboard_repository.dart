import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/data/models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardModel> getOwnerDashboard() async {
    final response = await _apiClient.get('/dashboard/owner');
    return DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
