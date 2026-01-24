import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';
import '../../../providers/providers.dart';

class ToolHistoryScreen extends ConsumerStatefulWidget {
  final ToolLibraryModel tool;

  const ToolHistoryScreen({
    super.key,
    required this.tool,
  });

  @override
  ConsumerState<ToolHistoryScreen> createState() => _ToolHistoryScreenState();
}

class _ToolHistoryScreenState extends ConsumerState<ToolHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final toolRepository = ref.read(toolRepositoryProvider);
      final history = await toolRepository.getToolHistory(widget.tool.toolId);
      
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHECKED_OUT':
        return Colors.orange;
      case 'RETURNED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getConditionColor(String? condition) {
    switch (condition?.toUpperCase()) {
      case 'GOOD':
        return Colors.green;
      case 'FAIR':
        return Colors.orange;
      case 'DAMAGED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool History'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Column(
        children: [
          // Tool Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tool.toolName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${widget.tool.toolCode ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${widget.tool.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading history',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadHistory,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No history available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This tool has not been checked out yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHistory,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final record = _history[index];
                                final isReturned = record['actual_return_time'] != null;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header with Status
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isReturned
                                                    ? Colors.green[100]
                                                    : Colors.orange[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isReturned ? 'RETURNED' : 'CHECKED OUT',
                                                style: TextStyle(
                                                  color: isReturned
                                                      ? Colors.green[900]
                                                      : Colors.orange[900],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Checkout #${record['id']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),

                                        // Checkout Information
                                        _buildInfoRow(
                                          icon: Icons.person,
                                          label: 'Checked out by',
                                          value: record['holder_name'] ?? 'Unknown',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.business,
                                          label: 'Project',
                                          value: record['project_name'] ?? 'Unknown',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.access_time,
                                          label: 'Checked out',
                                          value: _formatDateTime(record['checkout_time']),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.event,
                                          label: 'Expected return',
                                          value: _formatDateTime(record['expected_return_time']),
                                        ),

                                        // Return Information (if returned)
                                        if (isReturned) ...[
                                          const Divider(height: 24),
                                          _buildInfoRow(
                                            icon: Icons.check_circle,
                                            label: 'Returned on',
                                            value: _formatDateTime(record['actual_return_time']),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildInfoRow(
                                            icon: Icons.build,
                                            label: 'Return condition',
                                            value: record['return_condition'] ?? 'N/A',
                                            valueColor: _getConditionColor(
                                                record['return_condition']),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
