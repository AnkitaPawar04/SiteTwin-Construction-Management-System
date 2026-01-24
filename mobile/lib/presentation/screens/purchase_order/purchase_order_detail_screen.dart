import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/purchase_order_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

/// Purchase Order Detail Screen
/// Shows PO details and allows status updates (approve, deliver, close)
/// Purchase Manager can approve, Manager can mark delivered
class PurchaseOrderDetailScreen extends ConsumerStatefulWidget {
  final int purchaseOrderId;

  const PurchaseOrderDetailScreen({
    super.key,
    required this.purchaseOrderId,
  });

  @override
  ConsumerState<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState
    extends ConsumerState<PurchaseOrderDetailScreen> {
  bool _isLoading = false;
  PurchaseOrderModel? _purchaseOrder;

  @override
  void initState() {
    super.initState();
    _loadPurchaseOrder();
  }

  Future<void> _loadPurchaseOrder() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      final po = await repository.getPurchaseOrderById(widget.purchaseOrderId);

      setState(() {
        _purchaseOrder = po;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PO: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to $newStatus?'),
        content: Text('Are you sure you want to mark this PO as $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      // Send lowercase status to backend
      await repository.updateStatus(widget.purchaseOrderId, newStatus.toLowerCase());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PO status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPurchaseOrder(); // Reload
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor() {
    if (_purchaseOrder == null) return Colors.grey;
    
    switch (_purchaseOrder!.status.toUpperCase()) {
      case 'CREATED':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _purchaseOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_purchaseOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Order')),
        body: const Center(child: Text('Failed to load purchase order')),
      );
    }

    final po = _purchaseOrder!;

    return Scaffold(
      appBar: AppBar(
        title: Text(po.poNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPurchaseOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: _getStatusColor().withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status', style: TextStyle(fontSize: 12)),
                            Text(
                              po.status,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PO Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Purchase Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('PO Number', po.poNumber),
                      _buildInfoRow('PO Date', _formatDate(po.poDate)),
                      _buildInfoRow('Vendor', po.vendorName ?? 'Vendor #${po.vendorId}'),
                      _buildInfoRow('GST Type', po.gstType),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Items Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      ...po.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Quantity',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        Text(
                                          '${item.quantity} ${item.unit}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rate',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        Text(
                                          '₹${item.unitPrice.toStringAsFixed(2)}/${item.unit ?? 'unit'}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    if (item.gstRate > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'GST',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          Text(
                                            '${item.gstRate}%',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Amount',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '₹${item.totalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (index < po.items.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Divider(),
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

              // Total Card
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('₹${_calculateSubtotal(po).toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST'),
                          Text('₹${_calculateGST(po).toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${po.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget? _buildActionButton() {
    if (_purchaseOrder == null) return null;

    final status = _purchaseOrder!.status.toUpperCase();

    // Purchase Manager can approve CREATED POs
    if (status == 'CREATED') {
      return FloatingActionButton.extended(
        onPressed: () => _updateStatus(AppConstants.poApproved),
        icon: const Icon(Icons.check_circle),
        label: const Text('Approve PO'),
        backgroundColor: Colors.blue,
      );
    }

    // Manager can mark APPROVED POs as delivered
    if (status == 'APPROVED') {
      return FloatingActionButton.extended(
        onPressed: () => _updateStatus(AppConstants.poDelivered),
        icon: const Icon(Icons.local_shipping),
        label: const Text('Mark Delivered'),
        backgroundColor: Colors.green,
      );
    }

    // Manager can close DELIVERED POs
    if (status == 'DELIVERED') {
      return FloatingActionButton.extended(
        onPressed: () => _updateStatus(AppConstants.poClosed),
        icon: const Icon(Icons.done_all),
        label: const Text('Close PO'),
        backgroundColor: Colors.grey[700],
      );
    }

    return null;
  }

  IconData _getStatusIcon() {
    if (_purchaseOrder == null) return Icons.description;
    
    switch (_purchaseOrder!.status.toUpperCase()) {
      case 'CREATED':
        return Icons.create;
      case 'APPROVED':
        return Icons.check_circle;
      case 'DELIVERED':
        return Icons.local_shipping;
      case 'CLOSED':
        return Icons.done_all;
      default:
        return Icons.description;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal(PurchaseOrderModel po) {
    return po.items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateGST(PurchaseOrderModel po) {
    return po.items.fold(0.0, (sum, item) => sum + item.gstAmount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
