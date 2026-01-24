import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_cost_model.dart';

class UnitCostingScreen extends StatefulWidget {
  const UnitCostingScreen({super.key});

  @override
  State<UnitCostingScreen> createState() => _UnitCostingScreenState();
}

class _UnitCostingScreenState extends State<UnitCostingScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final NumberFormat _numberFormat = NumberFormat('#,##0.00');
  
  int? _selectedProjectId;
  List<UnitCostModel> _units = [];
  String _filterStatus = 'ALL'; // ALL, SOLD, UNSOLD, BLOCKED
  String _sortBy = 'UNIT_NUMBER'; // UNIT_NUMBER, COST, PROFIT
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUnitCosts();
  }

  Future<void> _loadUnitCosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final data = await costRepository.getUnitCosts(_selectedProjectId);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _units = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<UnitCostModel> get _filteredAndSortedUnits {
    var filtered = _units;
    
    // Apply filter
    if (_filterStatus != 'ALL') {
      filtered = filtered.where((u) => u.saleStatus == _filterStatus).toList();
    }
    
    // Apply sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'COST':
          return b.totalCost.compareTo(a.totalCost);
        case 'PROFIT':
          return b.profitMargin.compareTo(a.profitMargin);
        case 'UNIT_NUMBER':
        default:
          return a.unitNumber.compareTo(b.unitNumber);
      }
    });
    
    return filtered;
  }

  Map<String, int> get _statusCounts {
    return {
      'SOLD': _units.where((u) => u.isSold).length,
      'UNSOLD': _units.where((u) => u.isUnsold).length,
      'BLOCKED': _units.where((u) => u.saleStatus == 'BLOCKED').length,
    };
  }

  double get _totalRevenue {
    return _units.where((u) => u.isSold).fold(0.0, (sum, u) => sum + u.salePrice);
  }

  double get _totalCost {
    return _units.fold(0.0, (sum, u) => sum + u.totalCost);
  }

  double get _totalProfit {
    return _units.where((u) => u.isSold).fold(0.0, (sum, u) => sum + u.profitAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Costing'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort By',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'UNIT_NUMBER',
                child: Text('Unit Number'),
              ),
              const PopupMenuItem(
                value: 'COST',
                child: Text('Total Cost'),
              ),
              const PopupMenuItem(
                value: 'PROFIT',
                child: Text('Profit Margin'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnitCosts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          if (_units.isNotEmpty) _buildSummaryCards(),
          
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${_units.length})'),
                    selected: _filterStatus == 'ALL',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'ALL');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Sold (${_statusCounts['SOLD']})'),
                    selected: _filterStatus == 'SOLD',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'SOLD');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Unsold (${_statusCounts['UNSOLD']})'),
                    selected: _filterStatus == 'UNSOLD',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'UNSOLD');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Blocked (${_statusCounts['BLOCKED']})'),
                    selected: _filterStatus == 'BLOCKED',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'BLOCKED');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Revenue',
              _currencyFormat.format(_totalRevenue),
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Cost',
              _currencyFormat.format(_totalCost),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Profit',
              _currencyFormat.format(_totalProfit),
              Icons.trending_up,
              _totalProfit >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
              'Error loading unit costs',
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
              onPressed: _loadUnitCosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredAndSortedUnits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _units.isEmpty ? 'No Units Available' : 'No units match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _units.isEmpty
                  ? 'Unit costing data will appear after\nproject setup and cost allocation'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUnitCosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAndSortedUnits.length,
        itemBuilder: (context, index) {
          return _buildUnitCard(_filteredAndSortedUnits[index]);
        },
      ),
    );
  }

  Widget _buildUnitCard(UnitCostModel unit) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.block;
    
    if (unit.isSold) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (unit.isUnsold) {
      statusColor = Colors.blue;
      statusIcon = Icons.home;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUnitDetails(unit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: unit.isSold ? Colors.green.shade700 : unit.isUnsold ? Colors.blue.shade700 : Colors.grey.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              unit.unitNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                unit.unitType,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_numberFormat.format(unit.area)} sq.ft.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unit.saleStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: unit.isSold ? Colors.green.shade700 : unit.isUnsold ? Colors.blue.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Cost Breakdown
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Cost',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFormat.format(unit.totalCost),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_currencyFormat.format(unit.costPerSqft)}/sq.ft.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unit.isSold) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale Price',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(unit.salePrice),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profit',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(unit.profitAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: unit.isProfitable ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${unit.profitMargin.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: unit.isProfitable ? Colors.green.shade600 : Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cost Components
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cost Components',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCostComponent(
                            'Material',
                            unit.materialCost,
                            unit.totalCost,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCostComponent(
                            'Labor',
                            unit.laborCost,
                            unit.totalCost,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCostComponent(
                            'Overhead',
                            unit.overheadCost,
                            unit.totalCost,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostComponent(String label, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total) * 100 : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _showUnitDetails(UnitCostModel unit) {
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
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unit Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.unitNumber,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
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
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailRow('Project', unit.projectName),
                    _buildDetailRow('Unit Number', unit.unitNumber),
                    _buildDetailRow('Unit Type', unit.unitType),
                    _buildDetailRow('Sale Status', unit.saleStatus),
                    _buildDetailRow('Area', '${_numberFormat.format(unit.area)} sq.ft.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Cost Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Material Cost', _currencyFormat.format(unit.materialCost)),
                    _buildDetailRow('Labor Cost', _currencyFormat.format(unit.laborCost)),
                    _buildDetailRow('Overhead Cost', _currencyFormat.format(unit.overheadCost)),
                    _buildDetailRow('Total Cost', _currencyFormat.format(unit.totalCost)),
                    _buildDetailRow('Cost per Sq.Ft.', _currencyFormat.format(unit.costPerSqft)),
                    if (unit.isSold) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Sale Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Sale Price', _currencyFormat.format(unit.salePrice)),
                      _buildDetailRow('Profit', _currencyFormat.format(unit.profitAmount)),
                      _buildDetailRow('Profit Margin', '${unit.profitMargin.toStringAsFixed(2)}%'),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow('Updated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(unit.updatedAt))),
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
}
