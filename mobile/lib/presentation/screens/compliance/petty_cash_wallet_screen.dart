import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';

class PettyCashWalletScreen extends StatefulWidget {
  const PettyCashWalletScreen({super.key});

  @override
  State<PettyCashWalletScreen> createState() => _PettyCashWalletScreenState();
}

class _PettyCashWalletScreenState extends State<PettyCashWalletScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  
  List<PettyCashModel> _expenses = [];
  String _filterStatus = 'ALL'; // ALL, PENDING, APPROVED, REJECTED
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final data = await pettyCashRepository.getExpenses();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _expenses = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<PettyCashModel> get _filteredExpenses {
    if (_filterStatus == 'ALL') return _expenses;
    return _expenses.where((e) => e.status == _filterStatus).toList();
  }

  Map<String, int> get _statusCounts {
    return {
      'PENDING': _expenses.where((e) => e.isPending).length,
      'APPROVED': _expenses.where((e) => e.isApproved).length,
      'REJECTED': _expenses.where((e) => e.status == 'REJECTED').length,
    };
  }

  double get _totalExpense {
    return _filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _approvedTotal {
    return _expenses.where((e) => e.isApproved).fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petty Cash Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          if (_expenses.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(_totalExpense),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Approved',
                        _currencyFormat.format(_approvedTotal),
                        Icons.check_circle,
                      ),
                      Container(width: 1, height: 30, color: Colors.white30),
                      _buildSummaryItem(
                        'Pending',
                        '${_statusCounts['PENDING']}',
                        Icons.pending,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${_expenses.length})'),
                    selected: _filterStatus == 'ALL',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'ALL');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Pending (${_statusCounts['PENDING']})'),
                    selected: _filterStatus == 'PENDING',
                    avatar: const Icon(Icons.pending, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'PENDING');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Approved (${_statusCounts['APPROVED']})'),
                    selected: _filterStatus == 'APPROVED',
                    avatar: const Icon(Icons.check_circle, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'APPROVED');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Rejected (${_statusCounts['REJECTED']})'),
                    selected: _filterStatus == 'REJECTED',
                    avatar: const Icon(Icons.cancel, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'REJECTED');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadExpenses,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _expenses.isEmpty ? 'No Expenses' : 'No expenses match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _expenses.isEmpty
                  ? 'Add your first expense'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredExpenses.length,
        itemBuilder: (context, index) {
          return _buildExpenseCard(_filteredExpenses[index]);
        },
      ),
    );
  }

  Widget _buildExpenseCard(PettyCashModel expense) {
    MaterialColor statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    
    if (expense.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (expense.status == 'REJECTED') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    IconData categoryIcon = Icons.shopping_bag;
    MaterialColor categoryColor = Colors.blue;
    
    switch (expense.category) {
      case 'TRANSPORT':
        categoryIcon = Icons.directions_car;
        categoryColor = Colors.purple;
        break;
      case 'FOOD':
        categoryIcon = Icons.restaurant;
        categoryColor = Colors.orange;
        break;
      case 'MATERIAL':
        categoryIcon = Icons.inventory_2;
        categoryColor = Colors.teal;
        break;
      case 'MISC':
        categoryIcon = Icons.category;
        categoryColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showExpenseDetails(expense),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(categoryIcon, color: categoryColor[700]!, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expense.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor[700]!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(expense.expenseDate)),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFormat.format(expense.amount),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor[700]!),
                        const SizedBox(width: 6),
                        Text(
                          expense.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor[700]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Receipt and GPS indicators
              Row(
                children: [
                  if (expense.hasReceipt)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt, size: 12, color: Colors.green[700]!),
                          const SizedBox(width: 4),
                          Text(
                            'Receipt',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (expense.hasReceipt) const SizedBox(width: 8),
                  if (expense.isGPSVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.blue[700]!),
                          const SizedBox(width: 4),
                          Text(
                            'GPS Verified',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails(PettyCashModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expense Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(expense.amount),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailRow('Description', expense.description),
                    _buildDetailRow('Category', expense.category),
                    _buildDetailRow('Amount', _currencyFormat.format(expense.amount)),
                    _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(DateTime.parse(expense.expenseDate))),
                    _buildDetailRow('Status', expense.status),
                    if (expense.locationName != null)
                      _buildDetailRow('Location', expense.locationName!),
                    if (expense.approverName != null)
                      _buildDetailRow('Approved By', expense.approverName!),
                    if (expense.approvalRemarks != null)
                      _buildDetailRow('Remarks', expense.approvalRemarks!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addExpense() async {
    // TODO: Implement expense creation form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: const Text(
          'Expense entry form will include:\n\n'
          '• Category selection\n'
          '• Amount input\n'
          '• Description\n'
          '• Receipt photo capture\n'
          '• GPS location capture\n'
          '• Date selection',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
