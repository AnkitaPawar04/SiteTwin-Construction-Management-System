import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/stock_model.dart';
import 'package:mobile/data/models/stock_transaction_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            Tab(text: 'Transactions', icon: Icon(Icons.receipt)),
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(stockProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: stock.length,
            itemBuilder: (context, index) {
              final item = stock[index];
              final isLowStock = item.availableQuantity < 50; // Simple threshold

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLowStock ? Colors.orange : AppTheme.primaryColor,
                    child: Icon(
                      Icons.inventory,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    item.materialName ?? 'Material #${item.materialId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.projectName ?? 'Project #${item.projectId}'}\nUpdated: ${_formatDate(item.updatedAt)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.availableQuantity}',
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
                ),
              );
            },
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(stockTransactionsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIn = transaction.type == 'in';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIn ? Colors.green : Colors.red,
                    child: Icon(
                      isIn ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    transaction.materialName ?? 'Material #${transaction.materialId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${transaction.projectName ?? 'Project #${transaction.projectId}'}\n${_formatDateTime(transaction.createdAt)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIn ? '+' : '-'}${transaction.quantity}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isIn ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        transaction.materialUnit ?? 'units',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
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
