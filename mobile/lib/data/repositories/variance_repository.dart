import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';

class VarianceRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  VarianceRepository(
    this._apiClient,
    this._networkInfo,
  );

  Future<Map<String, dynamic>> getProjectVarianceReport(int projectId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching variance report');
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.varianceReport.replaceAll('{projectId}', projectId.toString());
      final response = await _apiClient.get(endpoint);
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch variance report', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMaterialVariance(int projectId, int materialId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching material variance');
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.materialVariance
          .replaceAll('{projectId}', projectId.toString())
          .replaceAll('{materialId}', materialId.toString());
      final response = await _apiClient.get(endpoint);
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch material variance', e);
      rethrow;
    }
  }
}
