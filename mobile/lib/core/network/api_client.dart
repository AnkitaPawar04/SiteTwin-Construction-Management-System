import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl, // Will be updated dynamically
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get dynamic server URL from preferences
          final prefs = await SharedPreferences.getInstance();
          final serverUrl = prefs.getString(AppConstants.serverUrlKey);
          if (serverUrl != null && serverUrl.isNotEmpty) {
            // Update base URL if custom URL is set
            options.baseUrl = serverUrl;
          }
          
          // Add auth token
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.debug('${options.method} ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            'API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            error,
          );
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<List<int>>> getBytes(String path, {Map<String, String>? headers}) {
    return _dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf',
          ...?headers,
        },
      ),
    );
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
  
  Future<Response> postFormData(String path, FormData formData) {
    return _dio.post(path, data: formData);
  }
}
