import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/repositories/offline_sync_repository.dart';
import 'package:mobile/data/repositories/attendance_repository.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/repositories/dpr_repository.dart';
import 'package:mobile/data/repositories/material_request_repository.dart';
import 'package:mobile/data/services/sync_queue_service.dart';
import 'package:mobile/providers/providers.dart';

/// Service to handle offline data synchronization
class OfflineSyncService {
  final OfflineSyncRepository _syncRepository;
  final NetworkInfo _networkInfo;
  final AttendanceRepository _attendanceRepository;
  final TaskRepository _taskRepository;
  final DprRepository _dprRepository;
  final MaterialRequestRepository _materialRequestRepository;
  final SyncQueueService _syncQueueService;

  OfflineSyncService(
    this._syncRepository,
    this._networkInfo,
    this._attendanceRepository,
    this._taskRepository,
    this._dprRepository,
    this._materialRequestRepository,
    this._syncQueueService,
  );

  /// Check if we can sync (online and have pending data)
  Future<bool> canSync() async {
    return await _networkInfo.isConnected;
  }

  /// Perform full sync of all offline data
  Future<void> performSync() async {
    if (!await canSync()) {
      AppLogger.info('Cannot sync - offline');
      return;
    }

    AppLogger.info('Starting offline sync...');
    final pendingCount = _syncQueueService.getPendingCount();
    AppLogger.info('Sync queue has $pendingCount pending items');

    try {
      // Sync attendance records
      await _attendanceRepository.syncPendingAttendance();
      AppLogger.info('Synced attendance records');

      // Sync task updates
      await _taskRepository.syncPendingTasks();
      AppLogger.info('Synced task updates');

      // Sync DPR submissions
      await _dprRepository.syncPendingDprs();
      AppLogger.info('Synced DPR submissions');

      // Sync material requests
      await _materialRequestRepository.syncPendingRequests();
      AppLogger.info('Synced material requests');

      AppLogger.info('Offline sync completed successfully');
    } catch (e) {
      AppLogger.error('Offline sync failed', e);
      rethrow;
    }
  }

  /// Get pending sync count
  int getPendingCount() {
    return _syncQueueService.getPendingCount();
  }

  /// Get sync queue items
  Future<List<dynamic>> getPendingItems() async {
    return _syncQueueService.getPendingItems();
  }

  /// Get server-side pending sync logs (for conflict resolution)
  Future<List<dynamic>> getPendingSyncLogs() async {
    if (!await canSync()) {
      throw Exception('Cannot fetch sync logs - offline');
    }

    return await _syncRepository.getPendingSyncLogs();
  }
}

/// Provider for OfflineSyncService
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    ref.watch(offlineSyncRepositoryProvider),
    ref.watch(networkInfoProvider),
    ref.watch(attendanceRepositoryProvider),
    ref.watch(taskRepositoryProvider),
    ref.watch(dprRepositoryProvider),
    ref.watch(materialRequestRepositoryProvider),
    ref.watch(syncQueueServiceProvider),
  );
});

/// Provider to trigger auto-sync when network becomes available
final autoSyncProvider = StreamProvider<bool>((ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  final syncService = ref.watch(offlineSyncServiceProvider);

  await for (final isConnected in networkInfo.onConnectivityChanged) {
    if (isConnected) {
      AppLogger.info('Network connected - triggering auto-sync');
      try {
        await syncService.performSync();
      } catch (e) {
        AppLogger.error('Auto-sync failed', e);
      }
    }
    yield isConnected;
  }
});
