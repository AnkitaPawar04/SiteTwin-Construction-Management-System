import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/dpr/dpr_create_screen.dart';

final myTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getMyTasks();
});

final allTasksProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return await repo.getAllTasks();
});

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    // Use allTasks for managers/owners, myTasks for workers/engineers
    final isManagerOrOwner = user?.role == 'manager' || user?.role == 'owner';
    final tasksAsync = ref.watch(isManagerOrOwner ? allTasksProvider : myTasksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myTasksProvider);
          ref.invalidate(allTasksProvider);
        },
        child: isManagerOrOwner
            ? _buildManagerView(context, ref, tasksAsync)
            : _buildWorkerView(context, tasksAsync),
      ),
    );
  }

  Widget _buildManagerView(BuildContext context, WidgetRef ref, AsyncValue<List<TaskModel>> tasksAsync) {
    return _TaskManagerView(tasksAsync: tasksAsync);
  }

  Widget _buildWorkerView(BuildContext context, AsyncValue<List<TaskModel>> tasksAsync) {
    return _TaskWorkerView(tasksAsync: tasksAsync);
  }
}

// Manager/Owner view with filtering
class _TaskManagerView extends ConsumerStatefulWidget {
  final AsyncValue<List<TaskModel>> tasksAsync;

  const _TaskManagerView({required this.tasksAsync});

  @override
  ConsumerState<_TaskManagerView> createState() => _TaskManagerViewState();
}

class _TaskManagerViewState extends ConsumerState<_TaskManagerView> {
  int? _projectFilter;
  int? _workerFilter;
  String? _statusFilter;

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    var filtered = tasks;
    
    if (_projectFilter != null) {
      filtered = filtered.where((task) => task.projectId == _projectFilter).toList();
    }
    
    if (_workerFilter != null) {
      filtered = filtered.where((task) => task.assignedTo == _workerFilter).toList();
    }
    
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      filtered = filtered.where((task) => task.status == _statusFilter).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return widget.tasksAsync.when(
      data: (tasks) {
        final projects = <int, String>{};
        final workers = <int, String>{};
        
        for (final task in tasks) {
          if (task.projectName != null) {
            projects[task.projectId] = task.projectName!;
          }
          if (task.assignedByName != null) {
            workers[task.assignedTo] = task.assignedByName!;
          }
        }
        
        final filteredTasks = _applyFilters(tasks);
        
        return Column(
          children: [
            _buildFilterSection(context, projects, workers),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No tasks found with selected filters'),
                        ],
                      ),
                    )
                  : _buildTaskList(filteredTasks),
            ),
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
              onPressed: () {
                ref.invalidate(allTasksProvider);
                ref.invalidate(myTasksProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, Map<int, String> projects, Map<int, String> workers) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: InputDecoration(
                    labelText: 'Project',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  initialValue: _projectFilter,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Projects')),
                    ...projects.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                  ],
                  onChanged: (value) {
                    setState(() => _projectFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: InputDecoration(
                    labelText: 'Worker',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  initialValue: _workerFilter,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Workers')),
                    ...workers.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                  ],
                  onChanged: (value) {
                    setState(() => _workerFilter = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  initialValue: _statusFilter,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Status')),
                    const DropdownMenuItem(value: AppConstants.taskPending, child: Text('Pending')),
                    const DropdownMenuItem(value: AppConstants.taskInProgress, child: Text('In Progress')),
                    const DropdownMenuItem(value: AppConstants.taskCompleted, child: Text('Completed')),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _projectFilter = null;
                      _workerFilter = null;
                      _statusFilter = null;
                    });
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    // Group tasks by status
    final pendingTasks = tasks.where((t) => t.status == AppConstants.taskPending).toList();
    final inProgressTasks = tasks.where((t) => t.status == AppConstants.taskInProgress).toList();
    final completedTasks = tasks.where((t) => t.status == AppConstants.taskCompleted).toList();
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (inProgressTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'In Progress', Colors.orange),
          ...inProgressTasks.map((task) => TaskCard(task: task, isManagerOrOwner: true)),
          const SizedBox(height: 16),
        ],
        if (pendingTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Pending', Colors.blue),
          ...pendingTasks.map((task) => TaskCard(task: task, isManagerOrOwner: true)),
          const SizedBox(height: 16),
        ],
        if (completedTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Completed', Colors.green),
          ...completedTasks.map((task) => TaskCard(task: task, isManagerOrOwner: true)),
        ],
      ],
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

// Worker/Engineer view - simple list of their tasks
class _TaskWorkerView extends ConsumerWidget {
  final AsyncValue<List<TaskModel>> tasksAsync;

  const _TaskWorkerView({required this.tasksAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tasksAsync.when(
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
              ...inProgressTasks.map((task) => TaskCard(task: task, isManagerOrOwner: false)),
              const SizedBox(height: 16),
            ],
            if (pendingTasks.isNotEmpty) ...[
              _buildSectionHeader(context, 'Pending', Colors.blue),
              ...pendingTasks.map((task) => TaskCard(task: task, isManagerOrOwner: false)),
              const SizedBox(height: 16),
            ],
            if (completedTasks.isNotEmpty) ...[
              _buildSectionHeader(context, 'Completed', Colors.green),
              ...completedTasks.map((task) => TaskCard(task: task, isManagerOrOwner: false)),
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
              onPressed: () {
                ref.invalidate(myTasksProvider);
              },
              child: const Text('Retry'),
            ),
          ],
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
  final bool isManagerOrOwner;
  
  const TaskCard({super.key, required this.task, this.isManagerOrOwner = false});
  
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
      ref.invalidate(allTasksProvider);
      
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

  Future<void> _deleteTask() async {
    setState(() => _isUpdating = true);
    
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(widget.task.id!);
      ref.invalidate(myTasksProvider);
      ref.invalidate(allTasksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
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
      child: InkWell(
        onTap: widget.isManagerOrOwner
            ? null
            : () {
                // For workers, navigate to DPR creation with this task pre-selected
                if (widget.task.status == AppConstants.taskInProgress) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DprCreateScreen(preSelectedTaskId: widget.task.id),
                    ),
                  );
                } else if (widget.task.status == AppConstants.taskPending) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Start the task first to submit a DPR'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and action buttons
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
                if (widget.isManagerOrOwner) ...[
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Task'),
                            content: const Text('Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTask();
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
            if (widget.isManagerOrOwner) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned to ID: ${widget.task.assignedTo}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (widget.task.assignedByName != null && !widget.isManagerOrOwner) ...[
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
            
            // Status change UI
            if (widget.isManagerOrOwner) ...[
              // Manager/Owner: Show dropdown to change status
              DropdownButtonFormField<String>(
                initialValue: widget.task.status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: [
                  DropdownMenuItem(value: AppConstants.taskPending, child: const Text('Pending')),
                  DropdownMenuItem(value: AppConstants.taskInProgress, child: const Text('In Progress')),
                  DropdownMenuItem(value: AppConstants.taskCompleted, child: const Text('Completed')),
                ],
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateStatus(newStatus);
                  }
                },
              ),
            ] else if (widget.task.status != AppConstants.taskCompleted) ...[
              // Worker/Engineer: Show action buttons for status progression
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
          ],
        ),
      ),
    );
  }
}
