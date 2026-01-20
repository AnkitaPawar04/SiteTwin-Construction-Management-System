import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/providers/providers.dart';

final myTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getMyTasks();
});

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myTasksProvider);
        },
        child: tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No tasks assigned'),
                  ],
                ),
              );
            }
            
            // Group tasks by status
            final pendingTasks = tasks.where((t) => t.status == AppConstants.taskPending).toList();
            final inProgressTasks = tasks.where((t) => t.status == AppConstants.taskInProgress).toList();
            final completedTasks = tasks.where((t) => t.status == AppConstants.taskCompleted).toList();
            
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (inProgressTasks.isNotEmpty) ...[
                  _buildSectionHeader(context, 'In Progress', Colors.orange),
                  ...inProgressTasks.map((task) => TaskCard(task: task)),
                  const SizedBox(height: 16),
                ],
                if (pendingTasks.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Pending', Colors.blue),
                  ...pendingTasks.map((task) => TaskCard(task: task)),
                  const SizedBox(height: 16),
                ],
                if (completedTasks.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Completed', Colors.green),
                  ...completedTasks.map((task) => TaskCard(task: task)),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(myTasksProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  
  const TaskCard({super.key, required this.task});
  
  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isUpdating = false;
  
  Color _getStatusColor() {
    switch (widget.task.status) {
      case AppConstants.taskPending:
        return Colors.blue;
      case AppConstants.taskInProgress:
        return Colors.orange;
      case AppConstants.taskCompleted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateTaskStatus(widget.task.id!, newStatus);
      ref.invalidate(myTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task status updated'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              widget.task.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            
            // Project & Assigned By
            if (widget.task.projectName != null) ...[
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    widget.task.projectName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (widget.task.assignedByName != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned by: ${widget.task.assignedByName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Status Actions
            if (!widget.task.isSynced)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.sync_disabled, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Pending sync',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (widget.task.status != AppConstants.taskCompleted)
              Row(
                children: [
                  if (widget.task.status == AppConstants.taskPending) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateStatus(AppConstants.taskInProgress),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (widget.task.status == AppConstants.taskInProgress) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateStatus(AppConstants.taskCompleted),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
