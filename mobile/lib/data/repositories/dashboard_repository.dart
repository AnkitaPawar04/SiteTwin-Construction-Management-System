import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/data/models/dashboard_model.dart';
import 'package:mobile/core/utils/app_logger.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  
  static const String _ownerDashboardKey = 'cached_owner_dashboard';
  static const String _managerDashboardKey = 'cached_manager_dashboard';
  static const String _workerDashboardKey = 'cached_worker_dashboard';

  DashboardRepository(this._apiClient);

  Future<DashboardModel> getOwnerDashboard() async {
    try {
      final response = await _apiClient.get('/dashboard/owner');
      final data = DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      
      // Cache the response for offline use
      await _cacheDashboard(_ownerDashboardKey, response.data['data']);
      
      return data;
    } on DioException catch (e) {
      AppLogger.warning('Failed to fetch owner dashboard from API, loading from cache', e);
      return await _loadCachedDashboard(_ownerDashboardKey);
    }
  }

  Future<DashboardModel> getManagerDashboard() async {
    try {
      final response = await _apiClient.get('/dashboard/manager');
      final data = DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      
      // Cache the response for offline use
      await _cacheDashboard(_managerDashboardKey, response.data['data']);
      
      return data;
    } on DioException catch (e) {
      AppLogger.warning('Failed to fetch manager dashboard from API, loading from cache', e);
      return await _loadCachedDashboard(_managerDashboardKey);
    }
  }

  Future<DashboardModel> getWorkerDashboard() async {
    try {
      final response = await _apiClient.get('/dashboard/worker');
      final data = DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      
      // Cache the response for offline use
      await _cacheDashboard(_workerDashboardKey, response.data['data']);
      
      return data;
    } on DioException catch (e) {
      AppLogger.warning('Failed to fetch worker dashboard from API, loading from cache', e);
      return await _loadCachedDashboard(_workerDashboardKey);
    }
  }
  
  Future<void> _cacheDashboard(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
      AppLogger.info('Dashboard cached successfully: $key');
    } catch (e) {
      AppLogger.error('Failed to cache dashboard: $key', e);
    }
  }
  
  Future<DashboardModel> _loadCachedDashboard(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(key);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        final data = jsonDecode(cachedData) as Map<String, dynamic>;
        AppLogger.info('Loaded dashboard from cache: $key');
        return DashboardModel.fromJson(data);
      }
    } catch (e) {
      AppLogger.error('Failed to load cached dashboard: $key', e);
    }
    
    // Return empty dashboard if no cache available
    AppLogger.warning('No cached dashboard available, returning empty dashboard');
    return DashboardModel(
      projectsCount: 0,
      projects: [],
      financialOverview: FinancialOverview(
        totalInvoices: 0,
        totalAmount: 0,
        totalGst: 0,
        paidAmount: 0,
        pendingAmount: 0,
      ),
      attendanceSummary: AttendanceSummary(
        todayAttendance: 0,
        totalWorkers: 0,
      ),
      materialConsumption: [],
    );
  }

  Future<Map<String, dynamic>> getTimeVsCostData() async {
    final response = await _apiClient.get('/dashboard/time-vs-cost');
    return response.data['data'] as Map<String, dynamic>;
  }
}
