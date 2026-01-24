import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/stock_model.dart';
import 'package:mobile/data/models/stock_transaction_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:mobile/presentation/screens/stock/stock_out_screen.dart';

// Providers
final stockProvider = FutureProvider.autoDispose<List<StockModel>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  return await repo.getAllStock();
});

final stockTransactionsProvider = FutureProvider.autoDispose<List<StockTransactionModel>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  return await repo.getAllTransactions();
});

class StockInventoryScreen extends ConsumerStatefulWidget {
  const StockInventoryScreen({super.key});

  @override
  ConsumerState<StockInventoryScreen> createState() =>
      _StockInventoryScreenState();
}

class _StockInventoryScreenState extends ConsumerState<StockInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _stockFilter = 'ALL'; // ALL, GST, NON_GST
  String _transactionFilter = 'ALL'; // ALL, IN, OUT
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock & Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Stock', icon: Icon(Icons.inventory)),
            Tab(text: 'History', icon: Icon(Icons.receipt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockList(),
          _buildTransactionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockOutScreen()),
          );
          if (result == true) {
            ref.invalidate(stockProvider);
            ref.invalidate(stockTransactionsProvider);
          }
        },
        label: const Text('Stock OUT'),
        icon: const Icon(Icons.remove_circle_outline),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Widget _buildStockList() {
    final stockAsync = ref.watch(stockProvider);

    return stockAsync.when(
      data: (stock) {
        if (stock.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No stock available'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _searchController.clear());
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  
                  // GST Filter Chips
                  Row(
                    children: [
                      const Text(
                        'GST Type:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All'),
                              selected: _stockFilter == 'ALL',
                              onSelected: (selected) {
                                setState(() => _stockFilter = 'ALL');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('GST'),
                              selected: _stockFilter == AppConstants.productGST,
                              onSelected: (selected) {
                                setState(() => _stockFilter = AppConstants.productGST);
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Non-GST'),
                              selected: _stockFilter == AppConstants.productNonGST,
                              onSelected: (selected) {
                                setState(() => _stockFilter = AppConstants.productNonGST);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Stock List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(stockProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: stock.length,
                  itemBuilder: (context, index) {
                    final item = stock[index];
                    
                    // Apply search filter
                    if (_searchController.text.isNotEmpty) {
                      final searchLower = _searchController.text.toLowerCase();
                      final materialName = (item.materialName ?? '').toLowerCase();
                      final projectName = (item.projectName ?? '').toLowerCase();
                      if (!materialName.contains(searchLower) && 
                          !projectName.contains(searchLower)) {
                        return const SizedBox.shrink();
                      }
                    }
                    
                    // TODO: Apply GST filter when material has GST type field
                    // For now, show all items
                    
                    final isLowStock = item.availableQuantity < 50; // Simple threshold

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: isLowStock ? Colors.orange : AppTheme.primaryColor,
                          child: const Icon(
                            Icons.inventory,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.materialName ?? 'Material #${item.materialId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (item.gstType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.gstType == 'GST' ? Colors.blue[50] : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.gstType!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.gstType == 'GST' ? Colors.blue[700] : Colors.orange[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text('Total: ${item.availableQuantity.toInt()} ${item.materialUnit ?? 'units'}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.availableQuantity.toInt()}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? Colors.orange : Colors.black,
                              ),
                            ),
                            Text(
                              item.materialUnit ?? 'units',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        children: [
                          if (item.projectWiseStock != null && item.projectWiseStock!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Project-wise Breakdown:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...item.projectWiseStock!.map((projectStock) => 
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              projectStock.projectName,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            '${projectStock.stock.toInt()} ${item.materialUnit ?? 'units'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).toList(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
              onPressed: () => ref.invalidate(stockProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactionsAsync = ref.watch(stockTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No transactions found'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Transaction Type Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Type:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _transactionFilter == 'ALL',
                        onSelected: (selected) {
                          setState(() => _transactionFilter = 'ALL');
                        },
                      ),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_downward, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            const Text('Stock IN'),
                          ],
                        ),
                        selected: _transactionFilter == 'IN',
                        onSelected: (selected) {
                          setState(() => _transactionFilter = 'IN');
                        },
                      ),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward, size: 14, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            const Text('Stock OUT'),
                          ],
                        ),
                        selected: _transactionFilter == 'OUT',
                        onSelected: (selected) {
                          setState(() => _transactionFilter = 'OUT');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(stockTransactionsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    
                    // Apply transaction type filter
                    if (_transactionFilter != 'ALL' && 
                        transaction.transactionType != _transactionFilter) {
                      return const SizedBox.shrink();
                    }
                    
                    final isIn = transaction.isStockIn;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIn ? Colors.green : Colors.red,
                              child: Icon(
                                isIn ? Icons.arrow_downward : Icons.arrow_upward,
                                color: Colors.white,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isIn ? 'Stock IN' : 'Stock OUT',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (transaction.isPendingSync)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.sync,
                                          size: 12,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pending Sync',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (transaction.projectName != null)
                                  Text(transaction.projectName!),
                                if (transaction.poNumber != null)
                                  Text('PO: ${transaction.poNumber}'),
                                if (transaction.vendorName != null)
                                  Text('Vendor: ${transaction.vendorName}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDateTime(transaction.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIn ? '+' : '-'}${transaction.totalQuantity.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isIn ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  '${transaction.items.length} items',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Items Preview (first 2 items)
                          if (transaction.items.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border(
                                  top: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Materials',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...transaction.items.take(2).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.isGST ? Colors.blue[50] : Colors.orange[50],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.gstType ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: item.isGST ? Colors.blue[700] : Colors.orange[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.materialName,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity.toStringAsFixed(2)} ${item.unit}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (transaction.items.length > 2)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '+${transaction.items.length - 2} more items',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
              onPressed: () => ref.invalidate(stockTransactionsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String value) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return '-';
    }
  }

  String _formatDateTime(String value) {
    try {
      return DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(value));
    } catch (_) {
      return '-';
    }
  }
}
