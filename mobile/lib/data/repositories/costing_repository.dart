import '../../core/network/api_client.dart';

class CostingRepository {
  final ApiClient _apiClient;

  CostingRepository(this._apiClient);

  /// Get flat costing (equal cost per unit) for a project
  Future<Map<String, dynamic>> getFlatCosting(int projectId) async {
    final response = await _apiClient.get('/costing/project/$projectId/flat-costing');
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get total project cost breakdown
  Future<Map<String, dynamic>> getProjectCost(int projectId) async {
    final response = await _apiClient.get('/costing/project/$projectId/cost');
    return response.data['data'] as Map<String, dynamic>;
  }
}
