import 'package:flutter/material.dart';
import '../../../data/models/compliance_models.dart';

class OTPPermitScreen extends StatefulWidget {
  const OTPPermitScreen({super.key});

  @override
  State<OTPPermitScreen> createState() => _OTPPermitScreenState();
}

class _OTPPermitScreenState extends State<OTPPermitScreen> {
  List<OTPPermitModel> _permits = [];
  String _filterStatus = 'ALL'; // ALL, PENDING, APPROVED, REJECTED
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPermits();
  }

  Future<void> _loadPermits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final data = await permitRepository.getOTPPermits();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _permits = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<OTPPermitModel> get _filteredPermits {
    if (_filterStatus == 'ALL') return _permits;
    return _permits.where((p) => p.status == _filterStatus).toList();
  }

  Map<String, int> get _statusCounts {
    return {
      'PENDING': _permits.where((p) => p.isPending).length,
      'APPROVED': _permits.where((p) => p.isApproved).length,
      'REJECTED': _permits.where((p) => p.status == 'REJECTED').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Permit-to-Work'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPermits,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${_permits.length})'),
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
        onPressed: _createPermit,
        icon: const Icon(Icons.add),
        label: const Text('Request Permit'),
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
              'Error loading permits',
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
              onPressed: _loadPermits,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPermits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _permits.isEmpty ? 'No Permits' : 'No permits match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _permits.isEmpty
                  ? 'Create a permit to start work'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPermits,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPermits.length,
        itemBuilder: (context, index) {
          return _buildPermitCard(_filteredPermits[index]);
        },
      ),
    );
  }

  Widget _buildPermitCard(OTPPermitModel permit) {
    MaterialColor statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;
    
    if (permit.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (permit.status == 'REJECTED') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (permit.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    MaterialColor hazardColor = Colors.blue;
    if (permit.hazardLevel == 'CRITICAL') {
      hazardColor = Colors.red;
    } else if (permit.hazardLevel == 'HIGH') {
      hazardColor = Colors.orange;
    } else if (permit.hazardLevel == 'MEDIUM') {
      hazardColor = Colors.yellow;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPermitDetails(permit),
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
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor[700]!, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          permit.permitNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          permit.workerName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      permit.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor[700]!,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Work Type & Hazard Level
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work Type',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          permit.workType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hazard Level',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hazardColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            permit.hazardLevel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hazardColor[700]!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      permit.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (permit.isOTPVerified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 18, color: Colors.green[700]!),
                      const SizedBox(width: 8),
                      Text(
                        'OTP Verified by ${permit.safetyOfficerName}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (permit.isCriticalHazard && !permit.isOTPVerified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 18, color: Colors.red[700]!),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Safety Officer verification required',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPermitDetails(OTPPermitModel permit) {
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
                            'Permit Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            permit.permitNumber,
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailRow('Worker', permit.workerName),
                    _buildDetailRow('Work Type', permit.workType),
                    _buildDetailRow('Hazard Level', permit.hazardLevel),
                    _buildDetailRow('Location', permit.location),
                    _buildDetailRow('Status', permit.status),
                    const SizedBox(height: 16),
                    const Text(
                      'Hazards',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...permit.hazards.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.warning, size: 16, color: Colors.orange[700]!),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text(
                      'Safety Measures',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...permit.safetyMeasures.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green[700]!),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    )),
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

  Future<void> _createPermit() async {
    // TODO: Implement permit creation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Permit'),
        content: const Text(
          'Permit creation form will include:\n\n'
          '• Work type selection\n'
          '• Hazard level assessment\n'
          '• Location details\n'
          '• Safety measures checklist\n'
          '• OTP verification request',
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
