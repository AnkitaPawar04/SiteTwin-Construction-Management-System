import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/providers.dart';

class FlatCostingScreen extends ConsumerStatefulWidget {
  const FlatCostingScreen({super.key});

  @override
  ConsumerState<FlatCostingScreen> createState() => _FlatCostingScreenState();
}

class _FlatCostingScreenState extends ConsumerState<FlatCostingScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  Map<String, dynamic>? _costData;
  bool _isLoading = false;
  String? _error;
  int? _selectedProjectId;
  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await ref.read(projectRepositoryProvider).getAllProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          if (projects.isNotEmpty) {
            _selectedProject = projects.first;
            _selectedProjectId = projects.first.id;
          }
        });
        if (_selectedProjectId != null) {
          _loadFlatCosting();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load projects: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadFlatCosting() async {
    if (_selectedProjectId == null) {
      setState(() {
        _error = 'No project selected';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final costingRepo = ref.read(costingRepositoryProvider);
      final data = await costingRepo.getFlatCosting(_selectedProjectId!);

      if (mounted) {
        setState(() {
          _costData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flat Costing'),
        backgroundColor: const Color(0xFF2C3E50),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlatCosting,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFlatCosting,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_costData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFlatCosting,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Selector Dropdown
            _buildProjectSelector(),
            const SizedBox(height: 20),

            // Project Header
            _buildProjectHeader(),
            const SizedBox(height: 20),

            // Total Project Cost Breakdown
            _buildCostBreakdownCard(),
            const SizedBox(height: 16),

            // Cost Per Flat
            _buildCostPerFlatCard(),
            const SizedBox(height: 16),

            // Sold vs Unsold
            _buildSoldUnsoldCard(),
            const SizedBox(height: 16),

            // Info Note
            _buildInfoNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector() {
    if (_projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Project',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProjectModel>(
              value: _selectedProject,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.business),
              ),
              items: _projects.map((project) {
                return DropdownMenuItem(
                  value: project,
                  child: Text(
                    project.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (project) {
                if (project != null) {
                  setState(() {
                    _selectedProject = project;
                    _selectedProjectId = project.id;
                  });
                  _loadFlatCosting();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.apartment,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _costData!['project_name'] ?? 'Project',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Equal Cost Distribution',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
    );
  }

  Widget _buildCostBreakdownCard() {
    final materialCost = (_costData!['material_cost'] ?? 0).toDouble();
    final laborCost = (_costData!['labor_cost'] ?? 0).toDouble();
    final miscCost = (_costData!['misc_cost'] ?? 0).toDouble();
    final totalCost = (_costData!['total_project_cost'] ?? 0).toDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Project Cost',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(totalCost),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const Divider(height: 32),
            _buildCostItem(
              'Material Cost',
              materialCost,
              totalCost,
              Icons.construction,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCostItem(
              'Labor Cost',
              laborCost,
              totalCost,
              Icons.person,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildCostItem(
              'Misc Expenses',
              miscCost,
              totalCost,
              Icons.attach_money,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(
    String label,
    double amount,
    double total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currencyFormat.format(amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostPerFlatCard() {
    final totalFlats = (_costData!['total_flats'] ?? 0);
    final costPerFlat = (_costData!['cost_per_flat'] ?? 0).toDouble();

    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Cost per Flat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(costPerFlat),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Flats: $totalFlats',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldUnsoldCard() {
    final soldFlats = (_costData!['sold_flats'] ?? 0);
    final unsoldFlats = (_costData!['unsold_flats'] ?? 0);
    final costAllocatedSold = (_costData!['cost_allocated_sold'] ?? 0).toDouble();
    final inventoryValueUnsold = (_costData!['inventory_value_unsold'] ?? 0).toDouble();
    final totalFlats = soldFlats + unsoldFlats;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sold vs Unsold Allocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Sold Flats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Sold Flats',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$soldFlats / $totalFlats',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cost Allocated',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(costAllocatedSold),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Unsold Flats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Unsold Flats',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$unsoldFlats / $totalFlats',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inventory Value',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(inventoryValueUnsold),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Card(
      elevation: 1,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Calculation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total project cost is equally distributed across all flats. '
                    'This shows cost visibility only and does not include profit calculations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
