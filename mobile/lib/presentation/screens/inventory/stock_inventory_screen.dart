import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';

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
    // Mock data for demonstration
    final mockStock = [
      {'material': 'Cement', 'unit': 'Bags', 'quantity': 150, 'minLevel': 50},
      {'material': 'Steel Bars', 'unit': 'Tons', 'quantity': 5.5, 'minLevel': 2},
      {'material': 'Bricks', 'unit': 'Pieces', 'quantity': 25000, 'minLevel': 10000},
      {'material': 'Sand', 'unit': 'Cu.Ft', 'quantity': 500, 'minLevel': 200},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockStock.length,
      itemBuilder: (context, index) {
        final item = mockStock[index];
        final isLow = (item['quantity'] as num) <= (item['minLevel'] as num);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLow
                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                  : AppTheme.successColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.inventory_2,
                color: isLow ? AppTheme.errorColor : AppTheme.successColor,
              ),
            ),
            title: Text(
              item['material'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Available: ${item['quantity']} ${item['unit']}'),
            trailing: isLow
                ? Chip(
                    label: const Text(
                      'LOW STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.errorColor,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    // Mock data for demonstration
    final mockTransactions = [
      {
        'date': '2026-01-20',
        'material': 'Cement',
        'type': 'IN',
        'quantity': 50,
        'unit': 'Bags',
        'reference': 'PO-001'
      },
      {
        'date': '2026-01-19',
        'material': 'Steel Bars',
        'type': 'OUT',
        'quantity': 1.5,
        'unit': 'Tons',
        'reference': 'MR-025'
      },
      {
        'date': '2026-01-18',
        'material': 'Bricks',
        'type': 'IN',
        'quantity': 10000,
        'unit': 'Pieces',
        'reference': 'PO-002'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockTransactions.length,
      itemBuilder: (context, index) {
        final txn = mockTransactions[index];
        final isIn = txn['type'] == 'IN';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIn
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.warningColor.withValues(alpha: 0.1),
              child: Icon(
                isIn ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIn ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ),
            title: Text(
              txn['material'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${txn['type']}: ${txn['quantity']} ${txn['unit']}\n'
              'Ref: ${txn['reference']} | ${txn['date']}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
