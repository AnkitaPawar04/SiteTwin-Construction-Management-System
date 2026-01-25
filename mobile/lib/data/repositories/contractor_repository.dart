import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';

class ContractorRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  ContractorRepository(
    this._apiClient,
    this._networkInfo,
  );

  Future<List<Map<String, dynamic>>> getContractors() async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching contractors');
      return [];
    }

    try {
      final response = await _apiClient.get(ApiConstants.contractors);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to fetch contractors', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createContractor({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.contractors,
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to create contractor', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getContractorTrades(int contractorId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      AppLogger.warning('No internet connection for fetching contractor trades');
      return [];
    }

    try {
      final endpoint = ApiConstants.contractorTrades.replaceAll('{id}', contractorId.toString());
      final response = await _apiClient.get(endpoint);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to fetch contractor trades', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addContractorTrade({
    required int contractorId,
    required String tradeType,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.contractorTrades.replaceAll('{id}', contractorId.toString());
      final response = await _apiClient.post(
        endpoint,
        data: {'trade_type': tradeType},
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to add contractor trade', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContractorSummary(int contractorId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.contractorSummary.replaceAll('{id}', contractorId.toString());
      final response = await _apiClient.get(endpoint);
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to fetch contractor summary', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitTradeRating({
    required int contractorId,
    required int tradeId,
    required int projectId,
    required int speed,
    required int quality,
    String? comments,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.contractorRatings,
        data: {
          'contractor_id': contractorId,
          'trade_id': tradeId,
          'project_id': projectId,
          'speed': speed,
          'quality': quality,
          if (comments != null && comments.isNotEmpty) 'comments': comments,
        },
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to submit trade rating', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTradeHistory(int tradeId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.tradeHistory.replaceAll('{id}', tradeId.toString());
      final response = await _apiClient.get(endpoint);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to fetch trade history', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProjectContractorRatings(int projectId) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final endpoint = ApiConstants.projectContractorRatings.replaceAll('{id}', projectId.toString());
      final response = await _apiClient.get(endpoint);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to fetch project contractor ratings', e);
      rethrow;
    }
  }
}
