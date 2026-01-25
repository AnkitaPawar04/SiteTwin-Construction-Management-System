import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';

class RateContractorScreen extends ConsumerStatefulWidget {
  const RateContractorScreen({super.key});

  @override
  ConsumerState<RateContractorScreen> createState() => _RateContractorScreenState();
}

class _RateContractorScreenState extends ConsumerState<RateContractorScreen> {
  // Step 1: Project Selection
  List<Map<String, dynamic>> _projects = [];
  Map<String, dynamic>? _selectedProject;
  
  // Step 2: Contractor Selection
  List<Map<String, dynamic>> _contractors = [];
  Map<String, dynamic>? _selectedContractor;
  
  // Step 3: Trades & Rating
  List<Map<String, dynamic>> _trades = [];
  Map<int, Map<String, int>> _ratings = {}; // trade_id -> {speed, quality}
  
  bool _isLoading = false;
  String? _error;
  final _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadContractors();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projectRepository = ref.read(projectRepositoryProvider);
      final projects = await projectRepository.getAllProjects();
      setState(() {
        _projects = projects.map((p) => {
          'id': p.id,
          'name': p.name,
          'location': p.location,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load projects: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadContractors() async {
    try {
      final contractorRepository = ref.read(contractorRepositoryProvider);
      final data = await contractorRepository.getContractors();
      setState(() => _contractors = data);
    } catch (e) {
      setState(() => _error = 'Failed to load contractors: $e');
    }
  }

  Future<void> _loadContractorTrades(int contractorId) async {
    setState(() => _isLoading = true);
    try {
      final contractorRepository = ref.read(contractorRepositoryProvider);
      final trades = await contractorRepository.getContractorTrades(contractorId);
      setState(() {
        _trades = trades;
        // Initialize ratings for each trade
        for (var trade in trades) {
          final tradeId = trade['id'] as int;
          _ratings[tradeId] = {'speed': 5, 'quality': 5};
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load trades: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateOverallRating() {
    if (_ratings.isEmpty) return 0.0;
    
    double totalRating = 0.0;
    for (var rating in _ratings.values) {
      final tradeRating = (rating['speed']! + rating['quality']!) / 2.0;
      totalRating += tradeRating;
    }
    
    return totalRating / _ratings.length;
  }

  Future<void> _submitRatings() async {
    if (_selectedProject == null || _selectedContractor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select project and contractor')),
      );
      return;
    }

    if (_trades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trades to rate')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final contractorRepository = ref.read(contractorRepositoryProvider);
      
      // Submit rating for each trade
      for (var trade in _trades) {
        final tradeId = trade['id'] as int;
        final rating = _ratings[tradeId]!;
        
        await contractorRepository.submitTradeRating(
          contractorId: _selectedContractor!['id'] as int,
          tradeId: tradeId,
          projectId: _selectedProject!['id'] as int,
          speed: rating['speed']!,
          quality: rating['quality']!,
          comments: _commentsController.text.trim().isEmpty 
            ? null 
            : _commentsController.text.trim(),
        );
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ratings submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset and go back
      Navigator.pop(context);
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit ratings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Contractor'),
        actions: [
          if (_selectedProject != null && _selectedContractor != null && _trades.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'View History',
              onPressed: _showTradeHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Project Selection
                  _buildProjectSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Debug: Show selected project
                  if (_selectedProject != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Project selected: ${_selectedProject!['name']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Step 2: Contractor Selection
                  if (_selectedProject != null) _buildContractorSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Message when contractor is selected but has no trades
                  if (_selectedContractor != null && _trades.isEmpty && !_isLoading)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'This contractor has no trades assigned. Please add trades to the contractor first before rating.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Step 3: Trades Rating
                  if (_selectedContractor != null && _trades.isNotEmpty) ...[
                    _buildTradesRating(),
                    
                    const SizedBox(height: 24),
                    
                    // Rating Calculation Display
                    _buildRatingCalculation(),
                    
                    const SizedBox(height: 24),
                    
                    // Comments
                    TextField(
                      controller: _commentsController,
                      decoration: const InputDecoration(
                        labelText: 'Comments (Optional)',
                        hintText: 'Add any additional comments',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.comment),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitRatings,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Submit Ratings'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                  
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProjectSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.business, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Step 1: Select Project',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_projects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No projects available. Please create a project first.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedProject,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Choose a project',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _projects.map((project) {
                  return DropdownMenuItem(
                    value: project,
                    child: Text(
                      '${project['name']} - ${project['location']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                    _selectedContractor = null;
                    _trades = [];
                    _ratings = {};
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractorSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Step 2: Select Contractor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_contractors.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No contractors available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please add contractors first from the Contractor Rating screen.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedContractor,
                decoration: const InputDecoration(
                  hintText: 'Choose a contractor',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                isExpanded: true,
                items: _contractors.map((contractor) {
                  final rating = contractor['overall_rating'] ?? 0.0;
                  return DropdownMenuItem(
                    value: contractor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            contractor['name'] ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: rating >= 7.0 
                            ? Colors.green.shade100 
                            : rating >= 5.0 
                              ? Colors.orange.shade100 
                              : Colors.red.shade100,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedContractor = value;
                    _trades = [];
                    _ratings = {};
                  });
                  if (value != null) {
                    await _loadContractorTrades(value['id'] as int);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star_rate, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Step 3: Rate Each Trade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._trades.map((trade) {
              final tradeId = trade['id'] as int;
              final tradeType = trade['trade_type'] ?? 'Unknown';
              final currentRatings = _ratings[tradeId]!;
              final tradeRating = (currentRatings['speed']! + currentRatings['quality']!) / 2.0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.build, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                tradeType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: tradeRating >= 7.0 
                                ? Colors.green 
                                : tradeRating >= 5.0 
                                  ? Colors.orange 
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tradeRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Speed Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Speed',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${currentRatings['speed']}/10',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentRatings['speed']!.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: currentRatings['speed'].toString(),
                            onChanged: (value) {
                              setState(() {
                                _ratings[tradeId]!['speed'] = value.round();
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Quality Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quality',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${currentRatings['quality']}/10',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentRatings['quality']!.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: currentRatings['quality'].toString(),
                            onChanged: (value) {
                              setState(() {
                                _ratings[tradeId]!['quality'] = value.round();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCalculation() {
    final overallRating = _calculateOverallRating();
    final color = overallRating >= 7.0 
      ? Colors.green 
      : overallRating >= 5.0 
        ? Colors.orange 
        : Colors.red;
    
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Overall Contractor Rating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '/ 10',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Calculation: Average of all trade ratings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _trades.map((trade) {
                final tradeId = trade['id'] as int;
                final tradeType = trade['trade_type'] ?? 'Unknown';
                final ratings = _ratings[tradeId]!;
                final tradeRating = (ratings['speed']! + ratings['quality']!) / 2.0;
                
                return Chip(
                  label: Text(
                    '$tradeType: ${tradeRating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showTradeHistory() {
    if (_selectedContractor == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TradeHistoryScreen(
          contractor: _selectedContractor!,
        ),
      ),
    );
  }
}

// Trade History Screen
class TradeHistoryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> contractor;

  const TradeHistoryScreen({
    super.key,
    required this.contractor,
  });

  @override
  ConsumerState<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends ConsumerState<TradeHistoryScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadContractorSummary();
  }

  Future<void> _loadContractorSummary() async {
    setState(() => _isLoading = true);
    try {
      final contractorRepository = ref.read(contractorRepositoryProvider);
      final summary = await contractorRepository.getContractorSummary(
        widget.contractor['id'] as int,
      );
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractorName = widget.contractor['name'] ?? 'Unknown';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$contractorName - History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? const Center(child: Text('No data available'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overall Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Rating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (_summary!['overall_rating'] ?? 0.0).toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Trades with Ratings
                    const Text(
                      'Trade Ratings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...(_summary!['trades'] as List<dynamic>? ?? []).map((trade) {
                      final tradeType = trade['trade_type'] ?? 'Unknown';
                      final avgRating = trade['trade_rating'] ?? 0.0;
                      final ratingsCount = trade['total_ratings'] ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.build, color: Colors.blue[700]),
                          ),
                          title: Text(tradeType),
                          subtitle: Text('$ratingsCount ratings'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: avgRating >= 7.0 
                                ? Colors.green 
                                : avgRating >= 5.0 
                                  ? Colors.orange 
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
