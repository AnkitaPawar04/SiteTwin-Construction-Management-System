import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

class MaterialRequestApprovalScreen extends ConsumerStatefulWidget {
  final MaterialRequestModel materialRequest;

  const MaterialRequestApprovalScreen({
    super.key,
    required this.materialRequest,
  });

  @override
  ConsumerState<MaterialRequestApprovalScreen> createState() =>
      _MaterialRequestApprovalScreenState();
}

class _MaterialRequestApprovalScreenState
    extends ConsumerState<MaterialRequestApprovalScreen> {
  bool _isLoading = false;
  final _remarksController = TextEditingController();
  late final Map<int, int> _allocatedQuantities;

  @override
  void initState() {
    super.initState();
    // Initialize allocated quantities with requested quantities
    _allocatedQuantities = {};
    for (var item in widget.materialRequest.items) {
      _allocatedQuantities[item.id] = item.quantity;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _handleApproval(bool isApproved) async {
    if (isApproved) {
      // Show quantity allocation dialog
      if (!mounted) return;
      final proceed = await _showQuantityAllocationDialog();
      if (proceed != true) return;
    }

    final action = isApproved ? 'approve' : 'reject';

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isApproved ? 'Approve' : 'Reject'} Material Request'),
        content: Text(
            'Are you sure you want to $action this material request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isApproved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(materialRequestRepositoryProvider);

      await repo.updateRequestStatus(
        widget.materialRequest.id,
        isApproved ? 'approved' : 'rejected',
        _remarksController.text.trim(),
        allocatedItems: isApproved ? _allocatedQuantities : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Material request ${isApproved ? 'approved' : 'rejected'} successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action request: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showQuantityAllocationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuantityAllocationDialog(
        items: widget.materialRequest.items,
        allocatedQuantities: _allocatedQuantities,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Request Approval'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request #${widget.materialRequest.id}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(widget.materialRequest.requestDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(widget.materialRequest.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Project Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Project #${widget.materialRequest.projectId}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Material Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested Materials',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.materialRequest.items.map((item) =>
                        _buildMaterialItem(context, item)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Remarks Input
            if (widget.materialRequest.status == 'pending')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remarks (Optional)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add any comments or feedback...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            if (widget.materialRequest.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _handleApproval(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _handleApproval(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return '-';
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return '-';
    }
  }

  Widget _buildMaterialItem(
      BuildContext context, MaterialRequestItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.materialName ?? 'Material #${item.materialId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity} ${item.unit ?? 'units'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = AppTheme.warningColor;
        icon = Icons.pending;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }
}

/// Quantity Allocation Dialog
class _QuantityAllocationDialog extends StatefulWidget {
  final List<MaterialRequestItemModel> items;
  final Map<int, int> allocatedQuantities;

  const _QuantityAllocationDialog({
    required this.items,
    required this.allocatedQuantities,
  });

  @override
  State<_QuantityAllocationDialog> createState() =>
      _QuantityAllocationDialogState();
}

class _QuantityAllocationDialogState extends State<_QuantityAllocationDialog> {
  late Map<int, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (var item in widget.items) {
      _controllers[item.id] = TextEditingController(
        text: widget.allocatedQuantities[item.id]?.toString() ?? item.quantity.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveAllocations() {
    for (var item in widget.items) {
      final value = int.tryParse(_controllers[item.id]?.text ?? '0') ?? 0;
      widget.allocatedQuantities[item.id] = value;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Allocate Quantities'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.materialName ?? 'Material #${item.materialId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested: ${item.quantity} ${item.unit ?? 'units'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controllers[item.id],
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Allocate quantity',
                      border: const OutlineInputBorder(),
                      suffixText: item.unit ?? 'units',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAllocations,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}