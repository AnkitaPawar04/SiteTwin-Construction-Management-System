import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

class MaterialRequestAllocationScreen extends ConsumerStatefulWidget {
  final MaterialRequestModel materialRequest;

  const MaterialRequestAllocationScreen({
    super.key,
    required this.materialRequest,
  });

  @override
  ConsumerState<MaterialRequestAllocationScreen> createState() =>
      _MaterialRequestAllocationScreenState();
}

class _MaterialRequestAllocationScreenState
    extends ConsumerState<MaterialRequestAllocationScreen> {
  bool _isLoading = false;
  final _remarksController = TextEditingController();
  late final Map<int, int> _allocatedQuantities;
  late final Map<int, TextEditingController> _quantityControllers;

  @override
  void initState() {
    super.initState();
    // Initialize allocated quantities with requested quantities
    _allocatedQuantities = {};
    _quantityControllers = {};
    
    for (var item in widget.materialRequest.items) {
      _allocatedQuantities[item.id] = item.quantity;
      _quantityControllers[item.id] = TextEditingController(
        text: item.quantity.toString(),
      );
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAllocation(bool approve) async {
    // Update allocated quantities from controllers
    for (var item in widget.materialRequest.items) {
      final value = int.tryParse(_quantityControllers[item.id]?.text ?? '0');
      if (value != null) {
        _allocatedQuantities[item.id] = value;
      }
    }

    // Validate allocations
    for (var item in widget.materialRequest.items) {
      final allocated = _allocatedQuantities[item.id] ?? 0;
      if (allocated < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allocated quantity cannot be negative'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      if (allocated > item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.materialName ?? 'Material'} allocation exceeds requested quantity',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    final action = approve ? 'Allocate and Approve' : 'Reject';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Material Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to $action this material request?'),
            if (approve) ...[
              const SizedBox(height: 16),
              const Text(
                'Allocation Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.materialRequest.items.map((item) {
                final allocated = _allocatedQuantities[item.id] ?? 0;
                final requested = item.quantity;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${item.materialName ?? 'Material #${item.materialId}'}: '
                    '$allocated / $requested ${item.unit ?? 'units'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
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
        approve ? 'approved' : 'rejected',
        _remarksController.text.trim(),
        allocatedItems: approve ? _allocatedQuantities : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Material request ${approve ? 'approved' : 'rejected'} successfully',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process request: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Request - Allocation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Request Info
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
                                widget.materialRequest.projectName ??
                                    'Project #${widget.materialRequest.projectId}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Requested by: ${widget.materialRequest.requestedByName ?? 'User #${widget.materialRequest.requestedBy}'}',
                                style: TextStyle(
                                  fontSize: 12,
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
                                widget.materialRequest.status.toUpperCase(),
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
                    if (widget.materialRequest.description != null &&
                        widget.materialRequest.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.materialRequest.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_formatDateTime(widget.materialRequest.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Materials & Allocation Section
            Text(
              'Material Allocation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Material Items with Allocation Fields
            ...widget.materialRequest.items.asMap().entries.map((entry) {
              final item = entry.value;
              return _buildMaterialAllocationCard(item);
            }),

            const SizedBox(height: 24),

            // Remarks Section
            Text(
              'Remarks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any remarks or notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (widget.materialRequest.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _submitAllocation(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _submitAllocation(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve & Allocate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Chip(
                  label: Text(
                    'Request is ${widget.materialRequest.status}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialAllocationCard(MaterialRequestItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material Name
            Text(
              item.materialName ?? 'Material #${item.materialId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Requested Quantity Display
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity} ${item.unit ?? 'units'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Allocation Input Field
            TextFormField(
              controller: _quantityControllers[item.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                labelText: 'Allocate Quantity',
                suffixText: item.unit ?? 'units',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  _allocatedQuantities[item.id] = parsed;
                }
              },
            ),

            // Allocation Warning
            if (_allocatedQuantities[item.id] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildAllocationStatus(item),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationStatus(MaterialRequestItemModel item) {
    final requested = item.quantity;
    final allocated = _allocatedQuantities[item.id] ?? 0;
    final remaining = requested - allocated;

    Color statusColor = Colors.green;
    String statusText = '✓ Fully Allocating';

    if (allocated < requested) {
      statusColor = Colors.orange;
      statusText = '⚠ Partial Allocation: $remaining units remaining';
    } else if (allocated > requested) {
      statusColor = Colors.red;
      statusText = '✗ Over Allocation by ${allocated - requested} units';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.materialRequest.status) {
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.materialRequest.status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      if (dateTimeString.isEmpty) return '-';
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime.toLocal());
    } catch (_) {
      return '-';
    }
  }
}
