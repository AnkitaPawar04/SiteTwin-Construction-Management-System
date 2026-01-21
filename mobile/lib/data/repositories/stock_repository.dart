import 'package:mobile/data/models/stock_model.dart';
import 'package:mobile/data/models/stock_transaction_model.dart';
import 'package:mobile/core/network/api_client.dart';

class StockRepository {
  final ApiClient _apiClient;

  StockRepository(this._apiClient);

  Future<List<StockModel>> getAllStock() async {
    final response = await _apiClient.get('/stock');
    final data = response.data['data'] as List;
    return data.map((json) => StockModel.fromJson(json)).toList();
  }

  Future<List<StockTransactionModel>> getAllTransactions() async {
    final response = await _apiClient.get('/stock-transactions');
    final data = response.data['data'] as List;
    return data.map((json) => StockTransactionModel.fromJson(json)).toList();
  }

  Future<List<StockModel>> getStockByProject(int projectId) async {
    final response = await _apiClient.get('/stock/project/$projectId');
    final data = response.data['data'] as List;
    return data.map((json) => StockModel.fromJson(json)).toList();
  }

  Future<List<StockTransactionModel>> getTransactionsByProject(int projectId) async {
    final response = await _apiClient.get('/stock/project/$projectId/transactions');
    final data = response.data['data'] as List;
    return data.map((json) => StockTransactionModel.fromJson(json)).toList();
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
      if (referenceId != null) 'reference_id': referenceId,
    });
    return StockModel.fromJson(response.data['data']);
  }
}
