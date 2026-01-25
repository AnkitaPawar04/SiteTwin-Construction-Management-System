import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import 'rate_contractor_screen.dart';

class ContractorRatingScreen extends ConsumerStatefulWidget {
  const ContractorRatingScreen({super.key});

  @override
  ConsumerState<ContractorRatingScreen> createState() => _ContractorRatingScreenState();
}

class _ContractorRatingScreenState extends ConsumerState<ContractorRatingScreen> {
  List<Map<String, dynamic>> _contractors = [];
  String _sortBy = 'NAME'; // NAME, RATING
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContractors();
  }

  Future<void> _loadContractors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contractorRepository = ref.read(contractorRepositoryProvider);
      final data = await contractorRepository.getContractors();
      
      setState(() {
        _contractors = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddContractorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Contractor'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contractor Name *',
                    hintText: 'Enter contractor name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    if (value.length < 10) {
                      return 'Phone must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'Enter email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@')) {
                        return 'Invalid email format';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    hintText: 'Enter address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final contractorRepository = ref.read(contractorRepositoryProvider);
                  await contractorRepository.createContractor(
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                  );
                  
                  if (!mounted) return;
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contractor created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  _loadContractors();
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create contractor: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _sortedContractors {
    var sorted = List<Map<String, dynamic>>.from(_contractors);
    
    switch (_sortBy) {
      case 'NAME':
        sorted.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
        break;
      case 'RATING':
      default:
        sorted.sort((a, b) {
          final ratingA = (a['overall_rating'] ?? 0.0) as num;
          final ratingB = (b['overall_rating'] ?? 0.0) as num;
          return ratingB.compareTo(ratingA);
        });
        break;
    }
    
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Ratings'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort By',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'NAME',
                child: Text('Name (A to Z)'),
              ),
              const PopupMenuItem(
                value: 'RATING',
                child: Text('Rating (High to Low)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContractors,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RateContractorScreen(),
                ),
              ).then((_) => _loadContractors());
            },
            heroTag: 'rate',
            child: const Icon(Icons.star_rate),
            tooltip: 'Rate Contractor',
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _showAddContractorDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Contractor'),
            tooltip: 'Add New Contractor',
            heroTag: 'add',
          ),
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
              'Error loading contractors',
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
              onPressed: _loadContractors,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sortedContractors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Contractors Available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Contractor ratings will appear here',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContractors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sortedContractors.length,
        itemBuilder: (context, index) {
          return _buildContractorCard(_sortedContractors[index]);
        },
      ),
    );
  }

  Widget _buildContractorCard(Map<String, dynamic> contractor) {
    final rating = (contractor['overall_rating'] ?? 0.0) as num;
    final name = contractor['name'] ?? 'Unknown';
    final phone = contractor['phone'] ?? 'N/A';
    final email = contractor['email'] ?? 'N/A';
    final address = contractor['address'] ?? 'N/A';
    final trades = contractor['trades'] as List<dynamic>? ?? [];
    
    MaterialColor ratingColor = Colors.grey;
    IconData ratingIcon = Icons.star;
    
    if (rating >= 7.0) {
      ratingColor = Colors.green;
      ratingIcon = Icons.star;
    } else if (rating >= 5.0) {
      ratingColor = Colors.orange;
      ratingIcon = Icons.star_half;
    } else {
      ratingColor = Colors.red;
      ratingIcon = Icons.star_border;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContractorDetails(contractor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: ratingColor.withValues(alpha: 0.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ratingColor[700]!,
                          ),
                        ),
                        Icon(ratingIcon, size: 16, color: ratingColor[700]!),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                color: Colors.grey.shade500,
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
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Trades
              if (trades.isNotEmpty) ...[
                const Text(
                  'Trades:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trades.map((trade) {
                    final tradeType = trade['trade_type'] ?? 'Unknown';
                    final avgRating = trade['average_rating'] ?? 0.0;
                    return Chip(
                      label: Text(
                        '$tradeType (${avgRating.toStringAsFixed(1)})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
              ] else
                Text(
                  'No trades assigned',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Address
              if (address != 'N/A')
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showContractorDetails(contractor),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TradeHistoryScreen(
                              contractor: contractor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('History'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  void _showContractorDetails(Map<String, dynamic> contractor) {
    final name = contractor['name'] ?? 'Unknown';
    final phone = contractor['phone'] ?? 'N/A';
    final email = contractor['email'] ?? 'N/A';
    final address = contractor['address'] ?? 'N/A';
    final rating = (contractor['overall_rating'] ?? 0.0) as num;
    final trades = contractor['trades'] as List<dynamic>? ?? [];
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
                            'Contractor Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
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
                    _buildDetailSection('Basic Information', [
                      _buildDetailRow('Name', name),
                      _buildDetailRow('Phone', phone),
                      _buildDetailRow('Email', email),
                      _buildDetailRow('Address', address),
                      _buildDetailRow('Overall Rating', '${rating.toStringAsFixed(1)} / 10.0'),
                    ]),
                    
                    if (trades.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Trades',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...trades.map((trade) {
                        final tradeType = trade['trade_type'] ?? 'Unknown';
                        final avgRating = trade['average_rating'] ?? 0.0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.build, color: Colors.blue[700]!),
                            ),
                            title: Text(tradeType),
                            trailing: Chip(
                              label: Text(avgRating.toStringAsFixed(1)),
                              backgroundColor: avgRating >= 7.0 ? Colors.green.shade100 : 
                                              avgRating >= 5.0 ? Colors.orange.shade100 : Colors.red.shade100,
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddTradeDialog(contractor);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Trade'),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
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

  void _showAddTradeDialog(Map<String, dynamic> contractor) {
    final contractorId = contractor['id'] as int;
    final contractorName = contractor['name'] ?? 'Unknown';
    final existingTrades = (contractor['trades'] as List<dynamic>? ?? [])
        .map((t) => t['trade_type'] as String)
        .toSet();

    // All available trade types from backend
    final availableTrades = [
      'Plumbing',
      'Electrical',
      'Tiling',
      'Painting',
      'Carpentry',
      'Masonry',
      'Plastering',
      'Waterproofing',
      'Flooring',
      'Roofing',
      'HVAC',
      'Other',
    ];

    // Filter out already assigned trades
    final unassignedTrades = availableTrades
        .where((trade) => !existingTrades.contains(trade))
        .toList();

    if (unassignedTrades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All trades have been assigned to this contractor'),
        ),
      );
      return;
    }

    String? selectedTrade;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Trade to $contractorName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a trade to add:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTrade,
                decoration: const InputDecoration(
                  labelText: 'Trade Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                items: unassignedTrades.map((trade) {
                  return DropdownMenuItem(
                    value: trade,
                    child: Text(trade),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedTrade = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedTrade == null
                  ? null
                  : () async {
                      try {
                        final contractorRepository = ref.read(contractorRepositoryProvider);
                        await contractorRepository.addContractorTrade(
                          contractorId: contractorId,
                          tradeType: selectedTrade!,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Trade "$selectedTrade" added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _loadContractors();
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add trade: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
