import 'package:mobile/data/models/purchase_order_model.dart';
import 'package:mobile/core/network/api_client.dart';

class PurchaseOrderRepository {
  final ApiClient _apiClient;

  PurchaseOrderRepository(this._apiClient);

  Future<List<PurchaseOrderModel>> getAllPurchaseOrders() async {
    final response = await _apiClient.get('/purchase-orders');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list
        .map((json) => PurchaseOrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PurchaseOrderModel>> getPurchaseOrdersByProject(int projectId) async {
    final response = await _apiClient.get('/purchase-orders?project_id=$projectId');
    final body = response.data;
    final list = body is List ? body : (body['data'] as List? ?? const []);
    return list
        .map((json) => PurchaseOrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PurchaseOrderModel> getPurchaseOrderById(int id) async {
    final response = await _apiClient.get('/purchase-orders/$id');
    return PurchaseOrderModel.fromJson(response.data['data']);
  }

  Future<PurchaseOrderModel> createPurchaseOrder({
    required int projectId,
    required int vendorId,
    int? materialRequestId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.post('/purchase-orders', data: {
      'project_id': projectId,
      'vendor_id': vendorId,
      if (materialRequestId != null) 'material_request_id': materialRequestId,
      'items': items,
    });
    return PurchaseOrderModel.fromJson(response.data['data']);
  }

  Future<PurchaseOrderModel> updateStatus(int id, String status) async {
    final response = await _apiClient.patch('/purchase-orders/$id/status', data: {
      'status': status,
    });
    return PurchaseOrderModel.fromJson(response.data['data']);
  }

  Future<PurchaseOrderModel> uploadInvoice({
    required int id,
    required String invoicePath,
    required String invoiceType,
    required String invoiceNumber,
  }) async {
    final response = await _apiClient.postFormData('/purchase-orders/$id/invoice', {
      'invoice': invoicePath,
      'invoice_type': invoiceType,
      'invoice_number': invoiceNumber,
    });
    return PurchaseOrderModel.fromJson(response.data['data']);
  }

  Future<void> deletePurchaseOrder(int id) async {
    await _apiClient.delete('/purchase-orders/$id');
  }
}
