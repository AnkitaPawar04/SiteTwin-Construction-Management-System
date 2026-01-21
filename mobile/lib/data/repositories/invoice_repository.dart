import 'package:mobile/data/models/invoice_model.dart';
import 'package:mobile/core/network/api_client.dart';

class InvoiceRepository {
  final ApiClient _apiClient;

  InvoiceRepository(this._apiClient);

  Future<List<InvoiceModel>> getAllInvoices() async {
    final response = await _apiClient.get('/invoices');
    final data = response.data['data'] as List;
    return data.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<List<InvoiceModel>> getInvoicesByProject(int projectId) async {
    final response = await _apiClient.get('/invoices/project/$projectId');
    final data = response.data['data'] as List;
    return data.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<InvoiceModel> getInvoice(int id) async {
    final response = await _apiClient.get('/invoices/$id');
    return InvoiceModel.fromJson(response.data['data']);
  }

  Future<InvoiceModel> createInvoice({
    required int projectId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.post('/invoices', data: {
      'project_id': projectId,
      'items': items,
    });
    return InvoiceModel.fromJson(response.data['data']);
  }

  Future<InvoiceModel> markAsPaid(int id) async {
    final response = await _apiClient.post('/invoices/$id/mark-paid');
    return InvoiceModel.fromJson(response.data['data']);
  }
}
