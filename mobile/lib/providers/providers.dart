import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/data/repositories/attendance_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/dpr_repository.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/repositories/material_request_repository.dart';
import 'package:mobile/data/repositories/stock_repository.dart';
import 'package:mobile/data/repositories/invoice_repository.dart';
import 'package:mobile/data/repositories/notification_repository.dart';

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

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
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
  );
});

final materialRequestRepositoryProvider = Provider<MaterialRequestRepository>((ref) {
  return MaterialRequestRepository(ref.watch(apiClientProvider));
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
