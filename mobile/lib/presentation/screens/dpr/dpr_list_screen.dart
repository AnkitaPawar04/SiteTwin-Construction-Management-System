import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/dpr/dpr_create_screen.dart';
import 'package:mobile/presentation/screens/dpr/dpr_approval_screen.dart';
import 'package:mobile/presentation/widgets/sync_status_badge.dart';

final myDprsProvider = FutureProvider.autoDispose<List<DprModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  
  // Owners and managers see all pending DPRs for approval
  if (user?.role == 'owner' || user?.role == 'manager') {
    return await repo.getPendingDprs();
  }
  
  // Workers and engineers see only their own DPRs
  return await repo.getMyDprs();
});

class DprFilterNotifier extends Notifier<String> {
  @override
  String build() {
    return 'all';
  }
  
  void setFilter(String status) {
    state = status;
  }
}

final dprFilterProvider = NotifierProvider<DprFilterNotifier, String>(
  () => DprFilterNotifier(),
);

class DprListScreen extends ConsumerWidget {
  const DprListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dprsAsync = ref.watch(myDprsProvider);
    final authState = ref.watch(authStateProvider);
    final statusFilter = ref.watch(dprFilterProvider);
    final user = authState.value;
    final isApprover = user?.role == 'owner' || user?.role == 'manager';
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myDprsProvider);
        },
        child: dprsAsync.when(
          data: (dprs) {
            // Filter DPRs by status
            var filteredDprs = dprs;
            if (statusFilter != 'all') {
              filteredDprs = filteredDprs.where((d) => d.status == statusFilter).toList();
            }
            
            if (filteredDprs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No progress reports yet'),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                // Filter bar for approvers
                if (isApprover) ...[
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            ref,
                            'All',
                            'all',
                            statusFilter == 'all',
                          ),
                          _buildFilterChip(
                            context,
                            ref,
                            'Submitted',
                            'submitted',
                            statusFilter == 'submitted',
                          ),
                          _buildFilterChip(
                            context,
                            ref,
                            'Approved',
                            'approved',
                            statusFilter == 'approved',
                          ),
                          _buildFilterChip(
                            context,
                            ref,
                            'Rejected',
                            'rejected',
                            statusFilter == 'rejected',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredDprs.length,
                    itemBuilder: (context, index) => DprCard(
                      dpr: filteredDprs[index],
                      isApprover: isApprover,
                      onTap: isApprover
                          ? () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DprApprovalScreen(dpr: filteredDprs[index]),
                                ),
                              );
                              if (result == true) {
                                ref.invalidate(myDprsProvider);
                              }
                            }
                          : null,
                      onApprove: isApprover
                          ? () async {
                              await _approveDpr(context, ref, filteredDprs[index]);
                            }
                          : null,
                      onReject: isApprover
                          ? () async {
                              await _rejectDpr(context, ref, filteredDprs[index]);
                            }
                          : null,
                    ),
                  ),
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
                  onPressed: () => ref.invalidate(myDprsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: user?.role == 'worker' || user?.role == 'engineer'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DprCreateScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New DPR'),
            )
          : null,
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(dprFilterProvider.notifier).setFilter(value);
        },
      ),
    );
  }

  Future<void> _approveDpr(
    BuildContext context,
    WidgetRef ref,
    DprModel dpr,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve DPR'),
        content: const Text('Are you sure you want to approve this Daily Progress Report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    
    if (confirmed ?? false) {
      try {
        final repo = ref.read(dprRepositoryProvider);
        await repo.approveDpr(dpr.id!, 'approved');
        ref.invalidate(myDprsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DPR approved successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _rejectDpr(
    BuildContext context,
    WidgetRef ref,
    DprModel dpr,
  ) async {
    final remarksController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject DPR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this Daily Progress Report?'),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                hintText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    
    if (confirmed ?? false) {
      try {
        final repo = ref.read(dprRepositoryProvider);
        await repo.rejectDpr(dpr.id!, remarksController.text);
        ref.invalidate(myDprsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DPR rejected successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class DprCard extends StatelessWidget {
  final DprModel dpr;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isApprover;
  
  const DprCard({
    super.key, 
    required this.dpr, 
    this.onTap,
    this.onApprove,
    this.onReject,
    this.isApprover = false,
  });
  
  Color _getStatusColor() {
    switch (dpr.status) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon() {
    switch (dpr.status) {
      case 'draft':
        return Icons.edit;
      case 'submitted':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(dpr.reportDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(date),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SyncStatusBadge(isSynced: dpr.isSynced, isSmall: true),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 16,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dpr.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Project
              if (dpr.projectName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dpr.projectName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Work Description
              Text(
                dpr.workDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Photos Count
              Row(
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dpr.photoUrls.length + dpr.localPhotoPaths.length} photos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (!dpr.isSynced)
                    const Row(
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
                ],
              ),
              
              // Action buttons for approvers
              if (isApprover && dpr.status == 'submitted') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
