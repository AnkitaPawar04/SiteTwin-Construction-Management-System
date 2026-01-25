import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_cost_model.dart';
import '../../../providers/providers.dart';

class ConsumptionVarianceScreen extends ConsumerStatefulWidget {
  final int? projectId;
  
  const ConsumptionVarianceScreen({super.key, this.projectId});

  @override
  ConsumerState<ConsumptionVarianceScreen> createState() => _ConsumptionVarianceScreenState();
}

class _ConsumptionVarianceScreenState extends ConsumerState<ConsumptionVarianceScreen> {
  final NumberFormat _numberFormat = NumberFormat('#,##0.00');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  
  int? _selectedProjectId;
  List<ConsumptionVarianceModel> _variances = [];
  List<Map<String, dynamic>> _projects = [];
  String _filterType = 'ALL'; // ALL, WASTAGE, SAVINGS, HIGH_VARIANCE
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    _loadProjects();
    if (_selectedProjectId != null) {
      _loadVarianceData();
    }
  }
  
  Future<void> _loadProjects() async {
    try {
      final projectRepository = ref.read(projectRepositoryProvider);
      final projects = await projectRepository.getAllProjects();
      setState(() {
        _projects = projects.map((p) => {'id': p.id, 'name': p.name}).toList();
        if (_projects.isNotEmpty && _selectedProjectId == null) {
          _selectedProjectId = _projects.first['id'] as int;
          _loadVarianceData();
        }
      });
    } catch (e) {
      // Silently fail, user can still manually select if needed
    }
  }

  Future<void> _loadVarianceData() async {
    final projectId = widget.projectId ?? _selectedProjectId;
    
    if (projectId == null) {
      setState(() {
        _variances = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final varianceRepository = ref.read(varianceRepositoryProvider);
      final projectRepository = ref.read(projectRepositoryProvider);
      
      final report = await varianceRepository.getProjectVarianceReport(projectId);
      
      // Get project name
      String projectName = 'Project';
      try {
        final project = _projects.firstWhere((p) => p['id'] == projectId);
        projectName = project['name'] as String;
      } catch (e) {
        // Project name not found in cache, use default
      }
      
      final variances = (report['variances'] as List<dynamic>?)?.map((item) {
        final data = item as Map<String, dynamic>;
        
        // Helper function to safely parse numeric values
        double parseDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is num) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }
        
        // Determine variance type
        String varianceType = 'NORMAL';
        final alertStatus = data['alert_status'] as String?;
        final variance = parseDouble(data['variance']);
        
        if (alertStatus == 'EXCEEDED') {
          varianceType = 'WASTAGE';
        } else if (variance < 0) {
          varianceType = 'SAVINGS';
        }
        
        // Calculate costs (simplified - using standard quantity as proxy)
        final standardQty = parseDouble(data['standard_quantity']);
        final actualQty = parseDouble(data['actual_consumption']);
        final variancePercentage = parseDouble(data['variance_percentage']);
        final unitCost = 100.0; // Simplified - actual cost should come from material master
        
        return {
          'project_id': projectId,
          'project_name': projectName,
          'material_id': data['material_id'],
          'material_name': data['material_name'] ?? 'Unknown',
          'unit': data['unit'] ?? 'units',
          'theoretical_quantity': standardQty,
          'actual_quantity': actualQty,
          'variance_quantity': variance,
          'variance_percentage': variancePercentage,
          'variance_type': varianceType,
          'theoretical_cost': standardQty * unitCost,
          'actual_cost': actualQty * unitCost,
          'cost_variance': variance * unitCost,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList() ?? [];
      
      setState(() {
        _variances = variances.map((e) => ConsumptionVarianceModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ConsumptionVarianceModel> get _filteredVariances {
    if (_filterType == 'ALL') return _variances;
    if (_filterType == 'WASTAGE') {
      return _variances.where((v) => v.isWastage).toList();
    }
    if (_filterType == 'SAVINGS') {
      return _variances.where((v) => v.isSavings).toList();
    }
    if (_filterType == 'HIGH_VARIANCE') {
      return _variances.where((v) => v.isHighVariance).toList();
    }
    return _variances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumption Variance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVarianceData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Project Selector
          if (_projects.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: DropdownButtonFormField<int>(
                value: _selectedProjectId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Project',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _projects.map((project) {
                  return DropdownMenuItem(
                    value: project['id'] as int,
                    child: Text(
                      project['name'] as String,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                  _loadVarianceData();
                },
              ),
            ),
          
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filterType == 'ALL',
                    onSelected: (selected) {
                      setState(() => _filterType = 'ALL');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, size: 14, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        const Text('Wastage'),
                      ],
                    ),
                    selected: _filterType == 'WASTAGE',
                    onSelected: (selected) {
                      setState(() => _filterType = 'WASTAGE');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_down, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        const Text('Savings'),
                      ],
                    ),
                    selected: _filterType == 'SAVINGS',
                    onSelected: (selected) {
                      setState(() => _filterType = 'SAVINGS');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        const Text('High Variance'),
                      ],
                    ),
                    selected: _filterType == 'HIGH_VARIANCE',
                    onSelected: (selected) {
                      setState(() => _filterType = 'HIGH_VARIANCE');
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
              'Error loading variance data',
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
              onPressed: _loadVarianceData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredVariances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _variances.isEmpty ? 'No Variance Data' : 'No items match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _variances.isEmpty
                  ? 'Variance analysis will appear after\nmaterial consumption tracking'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVarianceData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredVariances.length,
        itemBuilder: (context, index) {
          return _buildVarianceCard(_filteredVariances[index]);
        },
      ),
    );
  }

  Widget _buildVarianceCard(ConsumptionVarianceModel variance) {
    final isWastage = variance.isWastage;
    final isSavings = variance.isSavings;
    final isHighVariance = variance.isHighVariance;
    
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.remove;
    
    if (isWastage) {
      statusColor = Colors.red;
      statusIcon = Icons.trending_up;
    } else if (isSavings) {
      statusColor = Colors.green;
      statusIcon = Icons.trending_down;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showVarianceDetails(variance),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusIcon,
                      color: isWastage ? Colors.red.shade700 : isSavings ? Colors.green.shade700 : Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variance.materialName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variance.projectName,
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          variance.varianceType,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isWastage ? Colors.red.shade700 : isSavings ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (isHighVariance) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, size: 12, color: Colors.orange.shade700),
                            const SizedBox(width: 2),
                            Text(
                              'High',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Quantity Comparison
              Row(
                children: [
                  Expanded(
                    child: _buildQuantityColumn(
                      'Theoretical',
                      variance.theoreticalQuantity,
                      variance.unit,
                      Colors.blue,
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuantityColumn(
                      'Actual',
                      variance.actualQuantity,
                      variance.unit,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuantityColumn(
                      'Variance',
                      variance.varianceQuantity.abs(),
                      variance.unit,
                      statusColor,
                      showSign: true,
                      value: variance.varianceQuantity,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Variance Percentage Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Variance Percentage',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${variance.variancePercentage >= 0 ? '+' : ''}${variance.variancePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isWastage ? Colors.red.shade700 : isSavings ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (variance.variancePercentage.abs() / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cost Impact
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theoretical Cost',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(variance.theoreticalCost),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actual Cost',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(variance.actualCost),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Impact',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${variance.costVariance >= 0 ? '+' : ''}${_currencyFormat.format(variance.costVariance)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isWastage ? Colors.red.shade700 : isSavings ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildQuantityColumn(
    String label,
    double quantity,
    String unit,
    Color color, {
    bool showSign = false,
    double? value,
  }) {
    final displayValue = value ?? quantity;
    final sign = showSign && displayValue >= 0 ? '+' : '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$sign${_numberFormat.format(quantity)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _showVarianceDetails(ConsumptionVarianceModel variance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                            'Variance Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            variance.materialName,
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
                    _buildDetailRow('Project', variance.projectName),
                    _buildDetailRow('Material', variance.materialName),
                    _buildDetailRow('Unit', variance.unit),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow('Theoretical Quantity', _numberFormat.format(variance.theoreticalQuantity)),
                    _buildDetailRow('Actual Quantity', _numberFormat.format(variance.actualQuantity)),
                    _buildDetailRow('Variance', '${variance.varianceQuantity >= 0 ? '+' : ''}${_numberFormat.format(variance.varianceQuantity)} ${variance.unit}'),
                    _buildDetailRow('Variance %', '${variance.variancePercentage >= 0 ? '+' : ''}${variance.variancePercentage.toStringAsFixed(2)}%'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow('Theoretical Cost', _currencyFormat.format(variance.theoreticalCost)),
                    _buildDetailRow('Actual Cost', _currencyFormat.format(variance.actualCost)),
                    _buildDetailRow('Cost Variance', '${variance.costVariance >= 0 ? '+' : ''}${_currencyFormat.format(variance.costVariance)}'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow('Type', variance.varianceType),
                    _buildDetailRow('Updated', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(variance.updatedAt))),
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
            width: 140,
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
