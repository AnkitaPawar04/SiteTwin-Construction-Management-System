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

  /// Get list of units (flats) for a project
  /// status: 'sold', 'unsold', or null for all
  Future<List<Map<String, dynamic>>> getUnitsList(int projectId, {String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get(
      '/costing/project/$projectId/units-list',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  }
}
