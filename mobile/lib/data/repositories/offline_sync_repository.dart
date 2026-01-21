import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/utils/app_logger.dart';

class OfflineSyncRepository {
  final ApiClient _apiClient;

  OfflineSyncRepository(this._apiClient);

  /// Get pending sync logs from server
  Future<List<dynamic>> getPendingSyncLogs() async {
    try {
      final response = await _apiClient.get('/sync/pending');
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      AppLogger.error('Failed to get pending sync logs', e);
      rethrow;
    }
  }

  /// Sync batch of records to server
  Future<Map<String, dynamic>> syncBatch(List<Map<String, dynamic>> records) async {
    try {
      final response = await _apiClient.post('/sync/batch', data: {
        'records': records,
      });
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to sync batch', e);
      rethrow;
    }
  }

  /// Mark a sync log as synced
  Future<void> markAsSynced(int logId) async {
    try {
      await _apiClient.post('/sync/$logId/mark-synced');
      AppLogger.info('Marked sync log $logId as synced');
    } catch (e) {
      AppLogger.error('Failed to mark as synced', e);
      rethrow;
    }
  }
}
