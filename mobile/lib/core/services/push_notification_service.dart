import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/utils/app_logger.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.info('User granted permission: ${settings.authorizationStatus}');

    // Get token
    String? token = await _firebaseMessaging.getToken();
    AppLogger.info('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('App opened from notification: ${message.notification?.title}');
      _handleMessageOpenedApp(message);
    });
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    AppLogger.info('Handling background message: ${message.notification?.title}');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Handling foreground message');
    // Show notification or update UI
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Handling message opened app');
    // Navigate to specific screen based on message data
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    AppLogger.info('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    AppLogger.info('Unsubscribed from topic: $topic');
  }

  /// Subscribe to project-specific notifications
  Future<void> subscribeToProject(int projectId) async {
    await subscribeToTopic('project_$projectId');
  }

  /// Subscribe to role-specific notifications
  Future<void> subscribeToRole(String role) async {
    await subscribeToTopic('role_$role');
  }

  /// Subscribe to user-specific notifications
  Future<void> subscribeToUser(int userId) async {
    await subscribeToTopic('user_$userId');
  }

  /// Unsubscribe from project notifications
  Future<void> unsubscribeFromProject(int projectId) async {
    await unsubscribeFromTopic('project_$projectId');
  }
}
