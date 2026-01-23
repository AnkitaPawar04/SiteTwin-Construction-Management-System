class ApiConstants {
  // Base URL - Update this to your backend URL
  static const String baseUrl = 'http://192.168.1.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-domain.com/api'; // Production
  
  // Auth Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  
  // Projects
  static const String projects = '/projects';
  
  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String myAttendance = '/attendance/my';
  static const String allAttendance = '/attendance/all';
  static const String projectAttendance = '/attendance/project';
  
  // Tasks
  static const String tasks = '/tasks';
  static const String myTasks = '/tasks/my';
  
  // DPR
  static const String dprs = '/dprs';
  static const String myDprs = '/dprs/my';
  static const String dprsPending = '/dprs/pending/all';
  static const String dprApprove = '/dprs/{id}/approve';
  
  // Materials
  static const String materials = '/materials';
  
  // Material Requests
  static const String materialRequests = '/material-requests';
  static const String materialRequestsPending = '/material-requests/pending/all';
  static const String materialRequestApprove = '/material-requests/{id}/approve';
  
  // Stock
  static const String stock = '/stock';
  
  // Invoices
  static const String invoices = '/invoices';
  
  // Dashboard
  static const String dashboardOwner = '/dashboard/owner';
  static const String dashboardManager = '/dashboard/manager';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnread = '/notifications/unread';
  static const String notificationMarkRead = '/notifications/{id}/mark-read';
  
  // Offline Sync
  static const String offlineSync = '/offline-sync';
}
