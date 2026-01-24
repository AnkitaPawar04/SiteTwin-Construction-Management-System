class AppConstants {
  // App Info
  static const String appName = 'SiteTwin';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String serverUrlKey = 'server_url';
  
  // Hive Box Names
  static const String attendanceBox = 'attendance_box';
  static const String dprBox = 'dpr_box';
  static const String taskBox = 'task_box';
  static const String materialRequestBox = 'material_request_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String projectBox = 'project_box';
  
  // Location Settings
  static const double allowedDistanceInMeters = 100.0;
  
  // Image Compression
  static const int imageQuality = 70;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  
  // Sync Settings
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // User Roles
  static const String roleWorker = 'worker';
  static const String roleEngineer = 'engineer';
  static const String roleManager = 'manager';
  static const String roleOwner = 'owner';
  
  // Task Status
  static const String taskPending = 'pending';
  static const String taskInProgress = 'in_progress';
  static const String taskCompleted = 'completed';
  
  // DPR Status
  static const String dprDraft = 'draft';
  static const String dprSubmitted = 'submitted';
  static const String dprApproved = 'approved';
  static const String dprRejected = 'rejected';
  
  // Material Request Status
  static const String mrPending = 'pending';
  static const String mrApproved = 'approved';
  static const String mrRejected = 'rejected';
}
