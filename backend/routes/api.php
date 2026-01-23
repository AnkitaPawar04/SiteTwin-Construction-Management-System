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

    // Stock routes
    Route::get('/stock', [StockController::class, 'allStock']);
    Route::get('/stock/project/{projectId}', [StockController::class, 'index']);
    Route::get('/stock-transactions', [StockController::class, 'allTransactions']);
    Route::get('/stock/project/{projectId}/transactions', [StockController::class, 'transactions']);
    Route::post('/stock/add', [StockController::class, 'addStock']);
    Route::post('/stock/remove', [StockController::class, 'removeStock']);

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
});
