import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/presentation/screens/purchase_order/purchase_order_create_screen.dart';

/// Purchase Manager screen for reviewing material requests
/// and deciding procurement strategy (Fulfill from Stock vs Create PO)
class MaterialRequestProcurementScreen extends ConsumerStatefulWidget {
  final MaterialRequestModel materialRequest;

  const MaterialRequestProcurementScreen({
    super.key,
    required this.materialRequest,
  });

  @override
  ConsumerState<MaterialRequestProcurementScreen> createState() =>
      _MaterialRequestProcurementScreenState();
}

class _MaterialRequestProcurementScreenState
    extends ConsumerState<MaterialRequestProcurementScreen> {
  bool _isLoading = false;
  final _notesController = TextEditingController();
  final Map<int, int> _stockAvailability = {};

  @override
  void initState() {
    super.initState();
    _loadStockLevels();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadStockLevels() async {
    setState(() => _isLoading = true);
    
    try {
      // Load actual stock levels from repository
      final stockRepo = ref.read(stockRepositoryProvider);
      final stockList = await stockRepo.getAllStock();
      
      // Build map of material ID to total available stock
      for (var item in widget.materialRequest.items) {
        int totalStock = 0;
        
        // Find stock entries for this material
        for (var stock in stockList) {
          if (stock.materialId == item.materialId) {
            totalStock += stock.availableQuantity.toInt();
          }
        }
        
        _stockAvailability[item.materialId] = totalStock;
      }
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stock levels: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fulfillFromStock() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fulfill from Stock'),
        content: const Text(
          'This will mark the request as REVIEWED and allocate materials from current stock. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Fulfill'),
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
        AppConstants.materialRequestReviewed,
        _notesController.text.trim().isEmpty
            ? 'Fulfilled from existing stock'
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material request marked for stock fulfillment'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPurchaseOrder() async {
    // Navigate to PO creation screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseOrderCreateScreen(
          materialRequest: widget.materialRequest,
        ),
      ),
    );
    
    if (result == true && mounted) {
      // PO created successfully, go back to list
      Navigator.pop(context, true);
    }
  }

  Future<void> _rejectRequest() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide rejection notes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this material request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
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
        AppConstants.materialRequestRejected,
        _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material request rejected'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStockStatusColor(int requested, int available) {
    if (available >= requested) return Colors.green;
    if (available > 0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final canFulfillAll = widget.materialRequest.items.every((item) =>
        (_stockAvailability[item.materialId] ?? 0) >= item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Review'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading && _stockAvailability.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Request Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('Project', widget.materialRequest.projectName ?? 'Unknown'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Requested By', widget.materialRequest.requestedByName ?? 'Unknown'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Date', _formatDate(widget.materialRequest.createdAt)),
                          if (widget.materialRequest.description != null &&
                              widget.materialRequest.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.materialRequest.description!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Materials & Stock Availability
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text(
                                'Materials & Stock Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...widget.materialRequest.items.map((item) {
                            final available = _stockAvailability[item.materialId] ?? 0;
                            final stockColor = _getStockStatusColor(item.quantity, available);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.materialName ?? 'Material #${item.materialId}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: stockColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: stockColor),
                                        ),
                                        child: Text(
                                          available >= item.quantity ? 'IN STOCK' : 'LOW STOCK',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: stockColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStockInfo(
                                          'Requested',
                                          '${item.quantity} ${item.unit ?? 'units'}',
                                          Colors.blue,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildStockInfo(
                                          'Available',
                                          '$available ${item.unit ?? 'units'}',
                                          stockColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes/Comments Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Procurement Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add notes about stock fulfillment or PO requirements...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!_isLoading) ...[
                    // Fulfill from Stock Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: canFulfillAll ? _fulfillFromStock : null,
                        icon: const Icon(Icons.inventory),
                        label: const Text(
                          'FULFILL FROM STOCK',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Create PO Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _createPurchaseOrder,
                        icon: const Icon(Icons.description),
                        label: const Text(
                          'CREATE PURCHASE ORDER',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Reject Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _rejectRequest,
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          'REJECT REQUEST',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStockInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }
}
