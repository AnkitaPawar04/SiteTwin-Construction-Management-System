import 'package:mobile/data/models/compliance_models.dart';
import 'package:mobile/core/network/api_client.dart';

class ToolRepository {
  final ApiClient _apiClient;

  ToolRepository(this._apiClient);

  Future<List<ToolLibraryModel>> getAllTools({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get('/tools', queryParameters: queryParams);
    final data = response.data['data'] as List;
    return data.map((json) => ToolLibraryModel.fromJson(json)).toList();
  }

  Future<ToolLibraryModel> getToolById(int id) async {
    final response = await _apiClient.get('/tools/$id');
    return ToolLibraryModel.fromJson(response.data['data']);
  }

  Future<ToolLibraryModel> createTool({
    required String toolName,
    String? toolCode,
    String? qrCode,
    required String category,
    String? purchaseDate,
    double? purchasePrice,
    String? condition,
    String? description,
  }) async {
    final response = await _apiClient.post('/tools', data: {
      'tool_name': toolName,
      if (toolCode != null) 'tool_code': toolCode,
      if (qrCode != null) 'qr_code': qrCode,
      'category': category,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (condition != null) 'condition': condition,
      if (description != null) 'description': description,
    });
    return ToolLibraryModel.fromJson(response.data['data']);
  }

  Future<void> checkoutTool({
    required int toolId,
    required int projectId,
    required String expectedReturnTime,
    String? checkoutNotes,
  }) async {
    await _apiClient.post('/tools/checkout', data: {
      'tool_id': toolId,
      'project_id': projectId,
      'expected_return_time': expectedReturnTime,
      if (checkoutNotes != null) 'checkout_notes': checkoutNotes,
    });
  }

  Future<void> returnTool({
    required int checkoutId,
    required String returnCondition,
    String? returnNotes,
  }) async {
    await _apiClient.post('/tools/checkouts/$checkoutId/return', data: {
      'return_condition': returnCondition,
      if (returnNotes != null) 'return_notes': returnNotes,
    });
  }

  Future<List<dynamic>> getOverdueTools() async {
    final response = await _apiClient.get('/tools/overdue');
    return response.data['data'] as List;
  }

  Future<Map<String, dynamic>> getAvailabilityReport() async {
    final response = await _apiClient.get('/tools/availability-report');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getToolHistory(int toolId) async {
    final response = await _apiClient.get('/tools/$toolId/history');
    final data = response.data['data'] as Map<String, dynamic>;
    final history = data['checkout_history'] as List;
    return history.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<void> markAsLost(int checkoutId) async {
    await _apiClient.post('/tools/checkouts/$checkoutId/mark-lost');
  }
}
