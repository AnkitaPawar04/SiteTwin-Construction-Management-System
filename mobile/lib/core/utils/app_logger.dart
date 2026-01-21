import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
  
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  static void info(String message) {
    _logger.i(message);
  }
  
  static void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // Log error as part of message to avoid logger library issues
    if (error != null) {
      _logger.e('$message: $error', stackTrace: stackTrace);
    } else {
      _logger.e(message, stackTrace: stackTrace);
    }
  }
}
