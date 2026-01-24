import 'package:hive/hive.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/project_model.dart';

class ProjectRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final Box<ProjectModel> _projectBox;

  ProjectRepository(
    this._apiClient,
    this._networkInfo,
    this._projectBox,
  );

  // Get all projects (with offline caching)
  Future<List<ProjectModel>> getAllProjects() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get(ApiConstants.projects);
        
        final List<dynamic> data = response.data['data'] ?? response.data;
        final projects = data.map((json) => ProjectModel.fromJson(json)).toList();
        
        // Clear and update cache
        await _projectBox.clear();
        for (var project in projects) {
          await _projectBox.add(project);
        }
        
        AppLogger.info('Projects cached: ${projects.length}');
        
        return projects;
      } catch (e) {
        AppLogger.error('Failed to fetch projects online', e);
        // Fall back to cache
        return _projectBox.values.toList();
      }
    } else {
      // Offline: return cached data
      AppLogger.info('Offline: returning ${_projectBox.values.length} cached projects');
      return _projectBox.values.toList();
    }
  }

  // Get project by ID (offline-capable)
  Future<ProjectModel?> getProjectById(int id) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        final response = await _apiClient.get('${ApiConstants.projects}/$id');
        final project = ProjectModel.fromJson(response.data['data'] ?? response.data);
        
        // Update cache
        final existing = _projectBox.values.firstWhere(
          (p) => p.id == id,
          orElse: () => ProjectModel(
            id: 0,
            name: '',
            location: '',
            latitude: 0,
            longitude: 0,
            startDate: '',
            endDate: '',
            ownerId: 0,
          ),
        );
        
        if (existing.id != 0) {
          await existing.delete();
        }
        await _projectBox.add(project);
        
        return project;
      } catch (e) {
        AppLogger.error('Failed to fetch project $id online', e);
        // Fall back to cache
        try {
          return _projectBox.values.firstWhere((p) => p.id == id);
        } catch (e) {
          return null;
        }
      }
    } else {
      // Offline: return from cache
      try {
        return _projectBox.values.firstWhere((p) => p.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get cached projects count
  int getCachedProjectsCount() {
    return _projectBox.values.length;
  }

  // Check if projects are cached
  bool hasCache() {
    return _projectBox.values.isNotEmpty;
  }

  // Refresh cache (fetch from server and update local)
  Future<void> refreshCache() async {
    await getAllProjects();
  }
}
