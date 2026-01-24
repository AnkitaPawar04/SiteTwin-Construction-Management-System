import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/data/models/sync_queue_model.dart';
import 'package:mobile/data/repositories/attendance_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/dpr_repository.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/repositories/user_repository.dart';
import 'package:mobile/data/repositories/material_request_repository.dart';
import 'package:mobile/data/repositories/project_repository.dart';
import 'package:mobile/data/repositories/stock_repository.dart';
import 'package:mobile/data/repositories/invoice_repository.dart';
import 'package:mobile/data/repositories/notification_repository.dart';
import 'package:mobile/data/repositories/dashboard_repository.dart';
import 'package:mobile/data/repositories/offline_sync_repository.dart';
import 'package:mobile/data/services/sync_queue_service.dart';

// Core Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Hive Box Providers
final attendanceBoxProvider = Provider<Box<AttendanceModel>>((ref) {
  return Hive.box<AttendanceModel>(AppConstants.attendanceBox);
});

final taskBoxProvider = Provider<Box<TaskModel>>((ref) {
  return Hive.box<TaskModel>(AppConstants.taskBox);
});

final dprBoxProvider = Provider<Box<DprModel>>((ref) {
  return Hive.box<DprModel>(AppConstants.dprBox);
});

final materialRequestBoxProvider = Provider<Box<MaterialRequestModel>>((ref) {
  return Hive.box<MaterialRequestModel>(AppConstants.materialRequestBox);
});

final projectBoxProvider = Provider<Box<ProjectModel>>((ref) {
  return Hive.box<ProjectModel>(AppConstants.projectBox);
});

final syncQueueBoxProvider = Provider<Box<SyncQueueModel>>((ref) {
  return Hive.box<SyncQueueModel>(AppConstants.syncQueueBox);
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(attendanceBoxProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(taskBoxProvider),
  );
});

final dprRepositoryProvider = Provider<DprRepository>((ref) {
  return DprRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(dprBoxProvider),
    ref.watch(projectBoxProvider),
  );
});

final materialRequestRepositoryProvider = Provider<MaterialRequestRepository>((ref) {
  return MaterialRequestRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(materialRequestBoxProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(projectBoxProvider),
  );
});

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(ref.watch(syncQueueBoxProvider));
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(ref.watch(apiClientProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final offlineSyncRepositoryProvider = Provider<OfflineSyncRepository>((ref) {
  return OfflineSyncRepository(ref.watch(apiClientProvider));
});
