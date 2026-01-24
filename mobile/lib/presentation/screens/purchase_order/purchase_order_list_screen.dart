import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/purchase_order_model.dart';

/// Purchase Order List Screen
/// Shows all purchase orders with status filtering
class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  bool _isLoading = false;
  List<PurchaseOrderModel> _purchaseOrders = [];
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadPurchaseOrders();
  }

  Future<void> _loadPurchaseOrders() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from repository
      // Placeholder data for now
      _purchaseOrders = [];
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load purchase orders: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<PurchaseOrderModel> get _filteredPOs {
    if (_selectedFilter == 'ALL') return _purchaseOrders;
    return _purchaseOrders.where((po) => po.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('ALL', Icons.all_inclusive),
                _buildFilterChip(AppConstants.poCreated, Icons.create),
                _buildFilterChip(AppConstants.poApproved, Icons.check_circle),
                _buildFilterChip(AppConstants.poDelivered, Icons.local_shipping),
                _buildFilterChip(AppConstants.poClosed, Icons.done_all),
              ],
            ),
          ),

          // PO List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPOs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No purchase orders',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPurchaseOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPOs.length,
                          itemBuilder: (context, index) {
                            final po = _filteredPOs[index];
                            return _POCard(purchaseOrder: po);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, IconData icon) {
    final isSelected = _selectedFilter == status;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        avatar: Icon(icon, size: 18),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = status);
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _POCard extends StatelessWidget {
  final PurchaseOrderModel purchaseOrder;

  const _POCard({required this.purchaseOrder});

  Color _getStatusColor() {
    switch (purchaseOrder.status.toUpperCase()) {
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

  IconData _getStatusIcon() {
    switch (purchaseOrder.status.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to PO detail screen
        },
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
                          purchaseOrder.poNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purchaseOrder.vendorName ?? 'Vendor #${purchaseOrder.vendorId}',
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
                      color: _getStatusColor().withOpacity(0.1),
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
                          purchaseOrder.status,
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
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PO Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(purchaseOrder.poDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${purchaseOrder.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: purchaseOrder.isGST ? Colors.blue[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      purchaseOrder.gstType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: purchaseOrder.isGST ? Colors.blue[700] : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${purchaseOrder.items.length} item(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}
