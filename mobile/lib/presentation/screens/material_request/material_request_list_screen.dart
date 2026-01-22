import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/presentation/screens/material_request/material_request_create_screen.dart';
import 'package:mobile/presentation/screens/material_request/material_request_approval_screen.dart';

class MaterialRequestListScreen extends ConsumerStatefulWidget {
  const MaterialRequestListScreen({super.key});

  @override
  ConsumerState<MaterialRequestListScreen> createState() =>
      _MaterialRequestListScreenState();
}

class _MaterialRequestListScreenState
    extends ConsumerState<MaterialRequestListScreen> {
  bool _isLoading = false;
  List<MaterialRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(materialRequestRepositoryProvider);
      final user = ref.read(authStateProvider).value;
      
      // Load appropriate requests based on user role
      if (user?.isEngineer == true || user?.isManager == true || user?.isOwner == true) {
        _requests = await repository.getPendingRequests();
      } else {
        _requests = await repository.getMyRequests();
      }
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final canApprove = user?.isManager == true || user?.isOwner == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No material requests',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _MaterialRequestCard(
                        request: request,
                        canApprove: canApprove,
                        onTap: canApprove
                            ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MaterialRequestApprovalScreen(
                                      materialRequest: request,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadRequests();
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ),
      floatingActionButton: canApprove
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialRequestCreateScreen(),
                  ),
                );
                if (result == true) {
                  _loadRequests();
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _MaterialRequestCard extends StatelessWidget {
  final MaterialRequestModel request;
  final bool canApprove;
  final VoidCallback? onTap;

  const _MaterialRequestCard({
    required this.request,
    required this.canApprove,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (request.status) {
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.projectName ?? 'Project #${request.projectId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested by: ${request.requestedByName ?? 'User #${request.requestedBy}'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
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
                        request.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.description != null && request.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                request.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...request.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.materialName ?? 'Material #${item.materialId}'} - ${item.quantity} ${item.unit ?? 'units'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Text(
              'Created: ${_formatDateTime(request.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (canApprove && request.status == 'pending') ...[
              const SizedBox(height: 8),
              Text(
                'Tap to approve or reject',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
  String _formatDateTime(String dateTimeString) {
    try {
      if (dateTimeString.isEmpty) return '-';
      final dateTime = DateTime.parse(dateTimeString);
      return dateTime.toLocal().toString().split('.')[0];
    } catch (_) {
      return '-';
    }
  }}