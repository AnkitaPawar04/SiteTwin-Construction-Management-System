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
  
  // User Roles (aligned with new backend system)
  static const String roleWorker = 'worker';
  static const String roleSiteEngineer = 'site_engineer';
  static const String rolePurchaseManager = 'purchase_manager';
  static const String roleProjectManager = 'project_manager';
  static const String roleSafetyOfficer = 'safety_officer';
  static const String roleOwner = 'owner';
  
  // Legacy role mapping (backward compatibility)
  static const String roleEngineer = 'site_engineer'; // Maps to site_engineer
  static const String roleManager = 'project_manager'; // Maps to project_manager
  
  // Material Request Status
  static const String materialRequestPending = 'PENDING';
  static const String materialRequestReviewed = 'REVIEWED';
  static const String materialRequestApproved = 'APPROVED';
  static const String materialRequestRejected = 'REJECTED';
  
  // Purchase Order Status
  static const String poCreated = 'CREATED';
  static const String poApproved = 'APPROVED';
  static const String poDelivered = 'DELIVERED';
  static const String poClosed = 'CLOSED';
  
  // Stock Transaction Types
  static const String stockIn = 'IN';
  static const String stockOut = 'OUT';
  
  // Task Status (still used for work tracking)
  static const String taskPending = 'pending';
  static const String taskInProgress = 'in_progress';
  static const String taskCompleted = 'completed';
  
  // DPR Status (still used for daily progress)
  static const String dprDraft = 'draft';
  static const String dprSubmitted = 'submitted';
  static const String dprApproved = 'approved';
  static const String dprRejected = 'rejected';
  
  // Product Types
  static const String productGST = 'GST';
  static const String productNonGST = 'NON_GST';
  
  // Material Request Status
  static const String mrPending = 'pending';
  static const String mrApproved = 'approved';
  static const String mrRejected = 'rejected';
}
