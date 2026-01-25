import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/permit_repository.dart';
import '../../../providers/providers.dart';

class OTPPermitScreen extends ConsumerStatefulWidget {
  const OTPPermitScreen({super.key});

  @override
  ConsumerState<OTPPermitScreen> createState() => _OTPPermitScreenState();
}

class _OTPPermitScreenState extends ConsumerState<OTPPermitScreen> {
  List<Map<String, dynamic>> _permits = [];
  String _filterStatus = 'ALL'; // ALL, PENDING, APPROVED, IN_PROGRESS, COMPLETED, REJECTED
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
      final repository = ref.read(permitRepositoryProvider);
      final data = await repository.getPermits();
      
      setState(() {
        _permits = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPermits {
    if (_filterStatus == 'ALL') return _permits;
    return _permits.where((p) => p['status'] == _filterStatus).toList();
  }

  Map<String, int> get _statusCounts {
    return {
      'PENDING': _permits.where((p) => p['status'] == 'PENDING').length,
      'APPROVED': _permits.where((p) => p['status'] == 'APPROVED').length,
      'IN_PROGRESS': _permits.where((p) => p['status'] == 'IN_PROGRESS').length,
      'COMPLETED': _permits.where((p) => p['status'] == 'COMPLETED').length,
      'REJECTED': _permits.where((p) => p['status'] == 'REJECTED').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    // User should not be null
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final isSupervisor = user.role == 'supervisor';
    final isSafetyOfficer = user.role == 'safety_officer';
    
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
                    label: Text('In Progress (${_statusCounts['IN_PROGRESS']})'),
                    selected: _filterStatus == 'IN_PROGRESS',
                    avatar: const Icon(Icons.play_arrow, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'IN_PROGRESS');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Completed (${_statusCounts['COMPLETED']})'),
                    selected: _filterStatus == 'COMPLETED',
                    avatar: const Icon(Icons.done_all, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'COMPLETED');
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

  Widget _buildPermitCard(Map<String, dynamic> permit) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isSafetyOfficer = user?.role == 'safety_officer';
    final isSupervisor = user?.role == 'supervisor';
    
    final status = permit['status'] as String;
    final taskType = permit['task_type'] as String;
    final project = permit['project'] as Map<String, dynamic>?;
    final supervisor = permit['supervisor'] as Map<String, dynamic>?;
    
    MaterialColor statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;
    
    switch (status) {
      case 'APPROVED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'IN_PROGRESS':
        statusColor = Colors.blue;
        statusIcon = Icons.play_arrow;
        break;
      case 'COMPLETED':
        statusColor = Colors.teal;
        statusIcon = Icons.done_all;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
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
                          'Permit #${permit['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supervisor?['name'] ?? 'Unknown',
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
                      status,
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
              
              // Task Type & Project
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Type',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          taskType.replaceAll('_', ' '),
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
                          'Project',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project?['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                permit['description'] ?? '',
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Approve/Reject buttons for Safety Officer on PENDING permits
              if (isSafetyOfficer && status == 'PENDING') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approvePermit(permit['id']),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectPermit(permit['id']),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Verify OTP button for Supervisor on APPROVED permits
              if (isSupervisor && status == 'APPROVED') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _verifyOTP(permit['id']),
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Enter OTP & Start Work'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
              
              // Complete Work button for Supervisor on IN_PROGRESS permits
              if (isSupervisor && status == 'IN_PROGRESS') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _completeWork(permit['id']),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Complete Work'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPermitDetails(Map<String, dynamic> permit) {
    final project = permit['project'] as Map<String, dynamic>?;
    final supervisor = permit['supervisor'] as Map<String, dynamic>?;
    final safetyMeasures = (permit['safety_measures'] as String?)?.split('\n') ?? [];
    
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
                            'Permit #${permit['id']}',
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
                    _buildDetailRow('Supervisor', supervisor?['name'] ?? 'Unknown'),
                    _buildDetailRow('Task Type', (permit['task_type'] as String).replaceAll('_', ' ')),
                    _buildDetailRow('Project', project?['name'] ?? 'Unknown'),
                    _buildDetailRow('Status', permit['status'] ?? 'Unknown'),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(permit['description'] ?? ''),
                    const SizedBox(height: 16),
                    const Text(
                      'Safety Measures',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...safetyMeasures.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green[700]!),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.trim())),
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

  Future<void> _approvePermit(int id) async {
    try {
      final repository = ref.read(permitRepositoryProvider);
      final result = await repository.approvePermit(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Permit approved! OTP: ${result['data']['otp_code']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        _loadPermits();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectPermit(int id) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Permit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason *',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        final repository = ref.read(permitRepositoryProvider);
        await repository.rejectPermit(id, controller.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Permit rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadPermits();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _verifyOTP(int id) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the OTP provided by Safety Officer:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                hintText: 'Enter 6-digit OTP',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify & Start Work'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        final repository = ref.read(permitRepositoryProvider);
        await repository.verifyOTP(id, controller.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ OTP verified! Work started'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPermits();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeWork(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Work'),
        content: const Text('Are you sure the work has been completed safely?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(permitRepositoryProvider);
        await repository.completeWork(id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Work completed successfully'),
              backgroundColor: Colors.teal,
            ),
          );
          _loadPermits();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
