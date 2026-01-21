import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/dpr_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/dpr/dpr_create_screen.dart';
import 'package:mobile/presentation/screens/dpr/dpr_approval_screen.dart';

final myDprsProvider = FutureProvider.autoDispose<List<DprModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  return await repo.getMyDprs();
});

class DprListScreen extends ConsumerWidget {
  const DprListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dprsAsync = ref.watch(myDprsProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myDprsProvider);
        },
        child: dprsAsync.when(
          data: (dprs) {
            if (dprs.isEmpty) {
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
            
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dprs.length,
              itemBuilder: (context, index) => DprCard(
                dpr: dprs[index],
                onTap: user?.role == 'manager'
                    ? () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DprApprovalScreen(dpr: dprs[index]),
                          ),
                        );
                        if (result == true) {
                          ref.invalidate(myDprsProvider);
                        }
                      }
                    : null,
              ),
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
}

class DprCard extends StatelessWidget {
  final DprModel dpr;
  final VoidCallback? onTap;
  
  const DprCard({super.key, required this.dpr, this.onTap});
  
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
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}