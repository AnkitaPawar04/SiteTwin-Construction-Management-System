<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\DprController;
use App\Http\Controllers\Api\MaterialController;
use App\Http\Controllers\Api\MaterialRequestController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\InvoiceController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OfflineSyncController;
use App\Http\Controllers\Api\VendorController;
use App\Http\Controllers\Api\PurchaseOrderController;
use App\Http\Controllers\Api\CostingController;
use App\Http\Controllers\Api\ContractorRatingController;
use App\Http\Controllers\Api\DailyWagerController;
use App\Http\Controllers\Api\ToolController;
use App\Http\Controllers\Api\PermitController;
use App\Http\Controllers\Api\PettyCashController;

// Public routes
Route::post('/login', [AuthController::class, 'login'])->name('login');
Route::get('/dprs/{dprId}/photos/{photoId}', [DprController::class, 'getPhoto'])->name('dprs.photo');

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // User routes
    Route::apiResource('users', UserController::class);

    // Project routes
    Route::apiResource('projects', ProjectController::class);
    Route::get('/projects/{id}/users', [ProjectController::class, 'getUsers']);
    Route::post('/projects/{id}/assign-user', [ProjectController::class, 'assignUser']);
    Route::delete('/projects/{id}/users/{userId}', [ProjectController::class, 'removeUser']);

    // Attendance routes
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
    Route::post('/attendance/{id}/check-out', [AttendanceController::class, 'checkOut']);
    Route::get('/attendance/my', [AttendanceController::class, 'myAttendance']);
    Route::get('/attendance/all', [AttendanceController::class, 'allAttendance']);
    Route::get('/attendance/project/{projectId}', [AttendanceController::class, 'projectAttendance']);
    Route::get('/attendance/project/{projectId}/team-summary', [AttendanceController::class, 'teamSummary']);
    Route::get('/attendance/project/{projectId}/trends', [AttendanceController::class, 'attendanceTrends']);

    // Task routes - custom routes must come before apiResource
    Route::get('/tasks/my', [TaskController::class, 'index']);
    Route::apiResource('tasks', TaskController::class);
    Route::patch('/tasks/{id}/status', [TaskController::class, 'updateStatus']);

    // DPR routes - custom routes before apiResource to avoid id collision
    Route::get('/dprs/my', [DprController::class, 'index']);
    Route::get('/dprs/pending/all', [DprController::class, 'pending']);
    Route::apiResource('dprs', DprController::class)->only(['index', 'store', 'show']);
    Route::post('/dprs/{id}/approve', [DprController::class, 'approve']);
    Route::patch('/dprs/{id}/status', [DprController::class, 'updateStatus']);

    // Material routes
    Route::apiResource('materials', MaterialController::class);

    // Material Request routes
    Route::get('/material-requests/my', [MaterialRequestController::class, 'index']);
    Route::get('/material-requests/pending', [MaterialRequestController::class, 'pending']);
    Route::get('/material-requests/pending/all', [MaterialRequestController::class, 'pending']);
    Route::apiResource('material-requests', MaterialRequestController::class)->only(['index', 'store', 'show']);
    Route::post('/material-requests/{id}/approve', [MaterialRequestController::class, 'approve']);
    Route::post('/material-requests/{id}/receive', [MaterialRequestController::class, 'receive']);
    Route::patch('/material-requests/{id}/status', [MaterialRequestController::class, 'updateStatus']);
    Route::post('/material-requests/{id}/review', [MaterialRequestController::class, 'review']);

    // Vendor routes
    Route::apiResource('vendors', VendorController::class);

    // Purchase Order routes
    Route::get('/purchase-orders', [PurchaseOrderController::class, 'index']);
    Route::post('/purchase-orders', [PurchaseOrderController::class, 'store']);
    Route::get('/purchase-orders/{id}', [PurchaseOrderController::class, 'show']);
    Route::patch('/purchase-orders/{id}/status', [PurchaseOrderController::class, 'updateStatus']);
    Route::post('/purchase-orders/{id}/invoice', [PurchaseOrderController::class, 'uploadInvoice']);
    Route::delete('/purchase-orders/{id}', [PurchaseOrderController::class, 'destroy']);

    // Stock routes
    Route::get('/stock', [StockController::class, 'allStock']);
    Route::get('/stock/project/{projectId}', [StockController::class, 'index']);
    Route::get('/stock-transactions', [StockController::class, 'allTransactions']);
    Route::get('/stock/project/{projectId}/transactions', [StockController::class, 'transactions']);
    Route::post('/stock/add', [StockController::class, 'addStock']);
    Route::post('/stock/remove', [StockController::class, 'removeStock']);
    
    // PHASE 3: Stock reporting endpoints
    Route::get('/stock/project/{projectId}/report', [StockController::class, 'getProjectStock']);
    Route::get('/stock/movements', [StockController::class, 'getStockMovements']);
    Route::get('/stock/summary', [StockController::class, 'getStockSummary']);
    Route::post('/stock/out', [StockController::class, 'createStockOut']);

    // Invoice routes
    Route::get('/invoices', [InvoiceController::class, 'all']);
    Route::get('/invoices/project/{projectId}', [InvoiceController::class, 'index']);
    Route::post('/invoices', [InvoiceController::class, 'store']);
    Route::get('/invoices/{id}', [InvoiceController::class, 'show']);
    Route::post('/invoices/{id}/mark-paid', [InvoiceController::class, 'markAsPaid']);
    Route::get('/invoices/{id}/pdf', [InvoiceController::class, 'generatePdf']);
    Route::get('/invoices/{id}/view-pdf', [InvoiceController::class, 'viewPdf']);

    // Dashboard routes
    Route::get('/dashboard/owner', [DashboardController::class, 'ownerDashboard']);
    Route::get('/dashboard/manager', [DashboardController::class, 'managerDashboard']);
    Route::get('/dashboard/worker', [DashboardController::class, 'workerDashboard']);
    Route::get('/dashboard/time-vs-cost', [DashboardController::class, 'timeVsCost']);

    // Notification routes
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread', [NotificationController::class, 'unread']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    // Offline Sync routes
    Route::get('/sync/pending', [OfflineSyncController::class, 'pendingLogs']);
    Route::post('/sync/batch', [OfflineSyncController::class, 'syncBatch']);
    Route::post('/sync/{id}/mark-synced', [OfflineSyncController::class, 'markAsSynced']);

    // PHASE 4: Costing & Analytics routes
    Route::get('/costing/project/{projectId}/cost', [CostingController::class, 'getProjectCost']);
    Route::get('/costing/project/{projectId}/variance', [CostingController::class, 'getVarianceReport']);
    Route::get('/costing/project/{projectId}/material/{materialId}/variance', [CostingController::class, 'getMaterialVariance']);
    Route::get('/costing/project/{projectId}/flat-costing', [CostingController::class, 'getFlatCosting']);
    Route::get('/costing/project/{projectId}/units-list', [CostingController::class, 'getUnitsList']);
    Route::get('/costing/project/{projectId}/area-costing', [CostingController::class, 'getAreaBasedCosting']);
    Route::get('/costing/project/{projectId}/wastage-alerts', [CostingController::class, 'getWastageAlerts']);
    Route::get('/costing/project/{projectId}/unit-costing', [CostingController::class, 'getUnitWiseCosting']);
    
    // Consumption standards management
    Route::post('/costing/consumption-standards', [CostingController::class, 'storeConsumptionStandard']);
    Route::get('/costing/project/{projectId}/consumption-standards', [CostingController::class, 'getConsumptionStandards']);
    
    // Project units management
    Route::post('/costing/project-units', [CostingController::class, 'storeProjectUnit']);
    Route::get('/costing/project/{projectId}/units', [CostingController::class, 'getProjectUnits']);
    Route::patch('/costing/units/{unitId}/mark-sold', [CostingController::class, 'markUnitSold']);

    // PHASE 5: Advanced Field & Compliance Features

    // Contractor Rating routes
    Route::post('/contractor-ratings', [ContractorRatingController::class, 'store']);
    Route::get('/contractors/{contractorId}/ratings', [ContractorRatingController::class, 'getHistory']);
    Route::get('/contractors/{contractorId}/average-rating', [ContractorRatingController::class, 'getAverageRating']);
    Route::get('/contractors/needing-attention', [ContractorRatingController::class, 'getNeedingAttention']);

    // Daily Wager Attendance routes (Face Recall)
    Route::post('/daily-wagers/check-in', [DailyWagerController::class, 'checkIn']);
    Route::post('/daily-wagers/{attendanceId}/check-out', [DailyWagerController::class, 'checkOut']);
    Route::post('/daily-wagers/{attendanceId}/verify', [DailyWagerController::class, 'verify']);
    Route::post('/daily-wagers/{attendanceId}/reject', [DailyWagerController::class, 'reject']);
    Route::get('/daily-wagers/daily-report', [DailyWagerController::class, 'getDailyReport']);
    Route::get('/daily-wagers/wage-summary', [DailyWagerController::class, 'getWageSummary']);

    // Tool Library routes
    Route::get('/tools', [ToolController::class, 'index']);
    Route::get('/tools/{id}', [ToolController::class, 'show']);
    Route::post('/tools', [ToolController::class, 'store']);
    Route::post('/tools/checkout', [ToolController::class, 'checkout']);
    Route::post('/tools/checkouts/{checkoutId}/return', [ToolController::class, 'return']);
    Route::get('/tools/overdue', [ToolController::class, 'getOverdue']);
    Route::get('/tools/availability-report', [ToolController::class, 'getAvailabilityReport']);
    Route::get('/tools/{toolId}/history', [ToolController::class, 'getHistory']);
    Route::post('/tools/checkouts/{checkoutId}/mark-lost', [ToolController::class, 'markAsLost']);

    // Permit-to-Work routes (OTP-based)
    Route::post('/permits', [PermitController::class, 'store']);
    Route::post('/permits/{permitId}/generate-otp', [PermitController::class, 'generateOTP']);
    Route::post('/permits/{permitId}/verify-otp', [PermitController::class, 'verifyOTP']);
    Route::post('/permits/{permitId}/reject', [PermitController::class, 'reject']);
    Route::post('/permits/{permitId}/start-work', [PermitController::class, 'startWork']);
    Route::post('/permits/{permitId}/complete-work', [PermitController::class, 'completeWork']);
    Route::get('/permits/active', [PermitController::class, 'getActive']);
    Route::get('/permits/critical-risk', [PermitController::class, 'getCriticalRisk']);
    Route::get('/permits/statistics', [PermitController::class, 'getStatistics']);

    // Petty Cash routes (Geo-tagged)
    Route::post('/petty-cash', [PettyCashController::class, 'store']);
    Route::post('/petty-cash/{transactionId}/approve', [PettyCashController::class, 'approve']);
    Route::post('/petty-cash/{transactionId}/reject', [PettyCashController::class, 'reject']);
    Route::post('/petty-cash/{transactionId}/mark-reimbursed', [PettyCashController::class, 'markReimbursed']);
    Route::get('/petty-cash/pending', [PettyCashController::class, 'getPending']);
    Route::get('/petty-cash/summary', [PettyCashController::class, 'getSummary']);
    Route::get('/petty-cash/without-receipts', [PettyCashController::class, 'getWithoutReceipts']);
    Route::get('/petty-cash/gps-failures', [PettyCashController::class, 'getGPSFailures']);
});