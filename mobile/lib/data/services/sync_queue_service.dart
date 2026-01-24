import 'package:hive/hive.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/utils/app_logger.dart';
import 'package:mobile/data/models/sync_queue_model.dart';
import 'package:uuid/uuid.dart';

class SyncQueueService {
  final Box<SyncQueueModel> _syncQueueBox;

  SyncQueueService(this._syncQueueBox);

  // Add to sync queue
  Future<void> addToQueue({
    required String entityType,
    required String entityId,
    required String action,
  }) async {
    final queueItem = SyncQueueModel(
      id: const Uuid().v4(),
      entityType: entityType,
      entityId: entityId,
      action: action,
      timestamp: DateTime.now(),
    );

    await _syncQueueBox.add(queueItem);
    
    AppLogger.info('Added to sync queue: $entityType/$entityId ($action)');
  }

  // Get all pending sync items (FIFO order)
  List<SyncQueueModel> getPendingItems() {
    final items = _syncQueueBox.values.toList();
    // Sort by timestamp (oldest first - FIFO)
    items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return items;
  }

  // Get pending count
  int getPendingCount() {
    return _syncQueueBox.values.length;
  }

  // Remove from queue after successful sync
  Future<void> removeFromQueue(String queueId) async {
    final item = _syncQueueBox.values.firstWhere(
      (q) => q.id == queueId,
      orElse: () => SyncQueueModel(
        id: '',
        entityType: '',
        entityId: '',
        action: '',
        timestamp: DateTime.now(),
      ),
    );

    if (item.id.isNotEmpty) {
      final index = _syncQueueBox.values.toList().indexWhere((q) => q.id == queueId);
      if (index >= 0) {
        await _syncQueueBox.deleteAt(index);
        AppLogger.info('Removed from sync queue: $queueId');
      }
    }
  }

  // Update retry count on failure
  Future<void> incrementRetry(String queueId, String errorMessage) async {
    final item = _syncQueueBox.values.firstWhere(
      (q) => q.id == queueId,
      orElse: () => SyncQueueModel(
        id: '',
        entityType: '',
        entityId: '',
        action: '',
        timestamp: DateTime.now(),
      ),
    );

    if (item.id.isNotEmpty) {
      final updated = item.copyWith(
        retryCount: item.retryCount + 1,
        errorMessage: errorMessage,
      );
      
      final index = _syncQueueBox.values.toList().indexOf(item);
      await _syncQueueBox.putAt(index, updated);
      
      AppLogger.info('Retry count incremented for $queueId: ${updated.retryCount}');
      
      // Remove if max retries exceeded
      if (updated.retryCount >= AppConstants.syncRetryAttempts) {
        AppLogger.error('Max retries exceeded for $queueId, removing from queue');
        await _syncQueueBox.deleteAt(index);
      }
    }
  }

  // Clear all queue items
  Future<void> clearQueue() async {
    await _syncQueueBox.clear();
    AppLogger.info('Sync queue cleared');
  }

  // Get items by entity type
  List<SyncQueueModel> getItemsByType(String entityType) {
    return _syncQueueBox.values
        .where((item) => item.entityType == entityType)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
