import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';
import '../../../providers/providers.dart';
import 'add_tool_dialog.dart';
import 'tool_detail_dialog.dart';
import 'qr_scanner_screen.dart';

class ToolLibraryScreen extends ConsumerStatefulWidget {
  const ToolLibraryScreen({super.key});

  @override
  ConsumerState<ToolLibraryScreen> createState() => _ToolLibraryScreenState();
}

class _ToolLibraryScreenState extends ConsumerState<ToolLibraryScreen> {
  List<ToolLibraryModel> _tools = [];
  String _filterStatus = 'ALL'; // ALL, AVAILABLE, CHECKED_OUT, MAINTENANCE
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final toolRepository = ref.read(toolRepositoryProvider);
      final tools = await toolRepository.getAllTools();
      
      setState(() {
        _tools = tools;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ToolLibraryModel> get _filteredTools {
    if (_filterStatus == 'ALL') return _tools;
    return _tools.where((t) => t.status == _filterStatus).toList();
  }

  Map<String, int> get _statusCounts {
    return {
      'AVAILABLE': _tools.where((t) => t.isAvailable).length,
      'CHECKED_OUT': _tools.where((t) => t.isCheckedOut).length,
      'MAINTENANCE': _tools.where((t) => t.status == 'MAINTENANCE').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTools,
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
                    label: Text('All (${_tools.length})'),
                    selected: _filterStatus == 'ALL',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'ALL');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Available (${_statusCounts['AVAILABLE']})'),
                    selected: _filterStatus == 'AVAILABLE',
                    avatar: const Icon(Icons.check_circle, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'AVAILABLE');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Checked Out (${_statusCounts['CHECKED_OUT']})'),
                    selected: _filterStatus == 'CHECKED_OUT',
                    avatar: const Icon(Icons.assignment_return, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'CHECKED_OUT');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Maintenance (${_statusCounts['MAINTENANCE']})'),
                    selected: _filterStatus == 'MAINTENANCE',
                    avatar: const Icon(Icons.build, size: 16),
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'MAINTENANCE');
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
        onPressed: _showAddToolDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Tool'),
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
              'Error loading tools',
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
              onPressed: _loadTools,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredTools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _tools.isEmpty ? 'No Tools Available' : 'No tools match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _tools.isEmpty
                  ? 'Tool inventory will appear here'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTools,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTools.length,
        itemBuilder: (context, index) {
          return _buildToolCard(_filteredTools[index]);
        },
      ),
    );
  }

  Widget _buildToolCard(ToolLibraryModel tool) {
    MaterialColor statusColor = Colors.grey;
    IconData statusIcon = Icons.build;
    
    if (tool.isAvailable) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (tool.isCheckedOut) {
      statusColor = Colors.blue;
      statusIcon = Icons.assignment_return;
    } else if (tool.status == 'MAINTENANCE') {
      statusColor = Colors.orange;
      statusIcon = Icons.build_circle;
    }

    MaterialColor conditionColor = Colors.green;
    if (tool.condition == 'FAIR') {
      conditionColor = Colors.orange;
    } else if (tool.condition == 'DAMAGED') {
      conditionColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showToolDetail(tool),
        borderRadius: BorderRadius.circular(12),
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor[700]!, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.toolName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.toolCode ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tool.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: conditionColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tool.condition,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: conditionColor[700]!,
                              ),
                            ),
                          ),
                        ],
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
                    tool.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor[700]!,
                    ),
                  ),
                ),
              ],
            ),
            
            if (tool.isCheckedOut && tool.assignedToUserName != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue[700]!),
                        const SizedBox(width: 6),
                        Text(
                          'Assigned to: ${tool.assignedToUserName!}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700]!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (tool.checkOutTime != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Checked Out',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM, hh:mm a').format(DateTime.parse(tool.checkOutTime!)),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (tool.expectedReturnTime != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected Return',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM, hh:mm a').format(DateTime.parse(tool.expectedReturnTime!)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: tool.isOverdue ? Colors.red[700]! : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (tool.isOverdue) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 16, color: Colors.red[700]!),
                            const SizedBox(width: 6),
                            Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  tool.location,
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

  Future<void> _showToolDetail(ToolLibraryModel tool) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ToolDetailDialog(tool: tool),
    );

    if (result == true) {
      _loadTools(); // Reload tools after action
    }
  }

  Future<void> _showAddToolDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddToolDialog(),
    );

    if (result == true) {
      _loadTools(); // Reload tools after adding
    }
  }

  Future<void> _scanQRCode() async {
    try {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );

      if (scannedCode != null && mounted) {
        // Find tool by QR code or tool code
        final matchFound = _tools.any((tool) => 
          (tool.qrCode != null && tool.qrCode == scannedCode) || 
          (tool.toolCode != null && tool.toolCode == scannedCode)
        );

        if (matchFound) {
          final matchingTool = _tools.firstWhere(
            (tool) => 
              (tool.qrCode != null && tool.qrCode == scannedCode) || 
              (tool.toolCode != null && tool.toolCode == scannedCode),
          );
          // Show tool detail
          _showToolDetail(matchingTool);
        } else {
          // No matching tool found
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No tool found with code: $scannedCode'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}