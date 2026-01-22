import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiError(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiError(statusCode: $statusCode, message: $message)';

  factory ApiError.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String fallback = e.message ?? 'Request failed';

    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'] ?? fallback;
      final errors = data['errors'] is Map<String, dynamic> ? data['errors'] as Map<String, dynamic> : null;
      return ApiError(msg.toString(), statusCode: status, details: errors);
    }

    return ApiError(fallback, statusCode: status);
  }
}
