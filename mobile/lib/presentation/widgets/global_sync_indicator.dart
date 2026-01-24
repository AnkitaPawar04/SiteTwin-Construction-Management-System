import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple notifier for syncing state
class SyncState {
  final bool isSyncing;
  final String progress;

  const SyncState({
    this.isSyncing = false,
    this.progress = '',
  });

  SyncState copyWith({
    bool? isSyncing,
    String? progress,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      progress: progress ?? this.progress,
    );
  }
}

// Notifier class
class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    return const SyncState();
  }

  void startSyncing([String progress = '']) {
    state = SyncState(isSyncing: true, progress: progress);
  }

  void updateProgress(String progress) {
    state = state.copyWith(progress: progress);
  }

  void stopSyncing() {
    state = const SyncState();
  }
}

// Provider
final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncState>(
  () => SyncStateNotifier(),
);

class GlobalSyncIndicator extends ConsumerWidget {
  const GlobalSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    if (!syncState.isSyncing) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      color: Colors.blue.shade700,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Syncing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (syncState.progress.isNotEmpty)
                    Text(
                      syncState.progress,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
