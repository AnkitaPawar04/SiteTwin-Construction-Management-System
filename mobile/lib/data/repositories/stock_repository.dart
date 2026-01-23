import 'package:mobile/data/models/stock_model.dart';
import 'package:mobile/data/models/stock_transaction_model.dart';
import 'package:mobile/core/network/api_client.dart';

class StockRepository {
  final ApiClient _apiClient;

  StockRepository(this._apiClient);

  Future<List<StockModel>> getAllStock() async {
    final response = await _apiClient.get('/stock');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list.map((json) => StockModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<StockTransactionModel>> getAllTransactions() async {
    final response = await _apiClient.get('/stock-transactions');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list
        .map((json) => StockTransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<StockModel>> getStockByProject(int projectId) async {
    final response = await _apiClient.get('/stock/project/$projectId');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list.map((json) => StockModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<StockTransactionModel>> getTransactionsByProject(int projectId) async {
    final response = await _apiClient.get('/stock/project/$projectId/transactions');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list
        .map((json) => StockTransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<StockModel> addStock({
    required int projectId,
    required int materialId,
    required double quantity,
    int? referenceId,
  }) async {
    final response = await _apiClient.post('/stock/add', data: {
      'project_id': projectId,
      'material_id': materialId,
      'quantity': quantity,
      'type': 'in',
      if (referenceId != null) 'reference_id': referenceId,
    });
    return StockModel.fromJson(response.data['data']);
  }

  Future<StockModel> removeStock({
    required int projectId,
    required int materialId,
    required double quantity,
    int? referenceId,
  }) async {
    final response = await _apiClient.post('/stock/remove', data: {
      'project_id': projectId,
      'material_id': materialId,
      'quantity': quantity,
      'type': 'out',
      if (referenceId != null) 'reference_id': referenceId,
    });
    return StockModel.fromJson(response.data['data']);
  }
}
