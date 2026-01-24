import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';

class ContractorRatingScreen extends StatefulWidget {
  const ContractorRatingScreen({super.key});

  @override
  State<ContractorRatingScreen> createState() => _ContractorRatingScreenState();
}

class _ContractorRatingScreenState extends State<ContractorRatingScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  
  List<ContractorRatingModel> _contractors = [];
  String _sortBy = 'RATING'; // RATING, NAME, TOTAL_VALUE
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
      // TODO: Replace with actual API call
      // final data = await contractorRepository.getContractorRatings();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _contractors = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ContractorRatingModel> get _sortedContractors {
    var sorted = List<ContractorRatingModel>.from(_contractors);
    
    switch (_sortBy) {
      case 'NAME':
        sorted.sort((a, b) => a.contractorName.compareTo(b.contractorName));
        break;
      case 'TOTAL_VALUE':
        sorted.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        break;
      case 'RATING':
      default:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
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
                value: 'RATING',
                child: Text('Rating (High to Low)'),
              ),
              const PopupMenuItem(
                value: 'NAME',
                child: Text('Name (A to Z)'),
              ),
              const PopupMenuItem(
                value: 'TOTAL_VALUE',
                child: Text('Total Value (High to Low)'),
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

  Widget _buildContractorCard(ContractorRatingModel contractor) {
    MaterialColor ratingColor = Colors.grey;
    IconData ratingIcon = Icons.star;
    
    if (contractor.isGoodRating) {
      ratingColor = Colors.green;
      ratingIcon = Icons.star;
    } else if (contractor.isAverageRating) {
      ratingColor = Colors.orange;
      ratingIcon = Icons.star_half;
    } else if (contractor.isPoorRating) {
      ratingColor = Colors.red;
      ratingIcon = Icons.star_border;
    }

    MaterialColor paymentColor = Colors.green;
    IconData paymentIcon = Icons.check_circle;
    String paymentText = 'Good Payment';
    
    if (contractor.paymentAdvice == 'DELAYED') {
      paymentColor = Colors.red;
      paymentIcon = Icons.warning;
      paymentText = 'Payment Delayed';
    } else if (contractor.paymentAdvice == 'CAUTION') {
      paymentColor = Colors.orange;
      paymentIcon = Icons.error;
      paymentText = 'Payment Caution';
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
                          contractor.rating.toStringAsFixed(1),
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
                          contractor.contractorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contractor.company,
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
                              contractor.phone,
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
              
              // Payment Advice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: paymentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: paymentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(paymentIcon, color: paymentColor[700]!, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        paymentText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: paymentColor[700]!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Projects',
                      '${contractor.completedProjects}/${contractor.totalProjects}',
                      Icons.business,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Quality',
                      contractor.qualityScore.toStringAsFixed(1),
                      Icons.stars,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'On-Time',
                      '${contractor.onTimeDeliveryRate.toStringAsFixed(0)}%',
                      Icons.schedule,
                      Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Value',
                      _currencyFormat.format(contractor.totalValue),
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Last Project
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Last Project: ${DateFormat('dd MMM yyyy').format(DateTime.parse(contractor.lastProjectDate))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

  Widget _buildStatCard(String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color[700]!),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color[700]!,
            ),
          ),
        ],
      ),
    );
  }

  void _showContractorDetails(ContractorRatingModel contractor) {
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
                            contractor.contractorName,
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
                      _buildDetailRow('Company', contractor.company),
                      _buildDetailRow('Phone', contractor.phone),
                      _buildDetailRow('Overall Rating', '${contractor.rating.toStringAsFixed(1)} / 10.0'),
                      _buildDetailRow('Payment Advice', contractor.paymentAdvice),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailSection('Performance Metrics', [
                      _buildDetailRow('Total Projects', contractor.totalProjects.toString()),
                      _buildDetailRow('Completed Projects', contractor.completedProjects.toString()),
                      _buildDetailRow('Quality Score', '${contractor.qualityScore.toStringAsFixed(1)} / 10.0'),
                      _buildDetailRow('On-Time Delivery', '${contractor.onTimeDeliveryRate.toStringAsFixed(1)}%'),
                      _buildDetailRow('Total POs', contractor.totalPOs.toString()),
                      _buildDetailRow('Total Value', _currencyFormat.format(contractor.totalValue)),
                    ]),
                    
                    if (contractor.recentProjects.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Recent Projects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...contractor.recentProjects.map((project) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.business, color: Colors.blue[700]!),
                          ),
                          title: Text(project.projectName),
                          subtitle: Text('Rating: ${project.rating.toStringAsFixed(1)}'),
                          trailing: Chip(
                            label: Text(project.status),
                            labelStyle: const TextStyle(fontSize: 10),
                          ),
                        ),
                      )),
                    ],
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
}
