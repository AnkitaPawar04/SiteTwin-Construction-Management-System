import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';

class FaceRecallAttendanceScreen extends StatefulWidget {
  const FaceRecallAttendanceScreen({super.key});

  @override
  State<FaceRecallAttendanceScreen> createState() => _FaceRecallAttendanceScreenState();
}

class _FaceRecallAttendanceScreenState extends State<FaceRecallAttendanceScreen> {
  List<FaceRecallAttendanceModel> _attendances = [];
  String _filterStatus = 'ALL'; // ALL, CHECKED_IN, CHECKED_OUT
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final data = await attendanceRepository.getFaceRecallAttendances();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _attendances = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<FaceRecallAttendanceModel> get _filteredAttendances {
    if (_filterStatus == 'ALL') return _attendances;
    return _attendances.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recall Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendances,
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
                    label: Text('All (${_attendances.length})'),
                    selected: _filterStatus == 'ALL',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'ALL');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Checked In (${_attendances.where((a) => a.isCheckedIn).length})'),
                    selected: _filterStatus == 'CHECKED_IN',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'CHECKED_IN');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Checked Out (${_attendances.where((a) => a.isCheckedOut).length})'),
                    selected: _filterStatus == 'CHECKED_OUT',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'CHECKED_OUT');
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
        onPressed: _captureAttendance,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture Face'),
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
              'Error loading attendance',
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
              onPressed: _loadAttendances,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredAttendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _attendances.isEmpty ? 'No Attendance Records' : 'No records match filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _attendances.isEmpty
                  ? 'Capture face to mark attendance'
                  : 'Try selecting a different filter',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttendances,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAttendances.length,
        itemBuilder: (context, index) {
          return _buildAttendanceCard(_filteredAttendances[index]);
        },
      ),
    );
  }

  Widget _buildAttendanceCard(FaceRecallAttendanceModel attendance) {
    MaterialColor statusColor = attendance.isCheckedIn ? Colors.green : Colors.blue;
    IconData statusIcon = attendance.isCheckedIn ? Icons.login : Icons.logout;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Photo placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                    image: attendance.photoPath.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(attendance.photoPath),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: attendance.photoPath.isEmpty
                      ? Icon(Icons.person, size: 32, color: Colors.grey.shade400)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendance.workerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor[700]!),
                          const SizedBox(width: 4),
                          Text(
                            attendance.status.replaceAll('_', ' '),
                            style: TextStyle(
                              color: statusColor[700]!,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendance.locationType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
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
                  child: Icon(statusIcon, color: statusColor[700]!, size: 24),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Times
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.login, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Check In',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('hh:mm a').format(DateTime.parse(attendance.checkInTime)),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (attendance.checkOutTime != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.logout, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Check Out',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.parse(attendance.checkOutTime!)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            if (attendance.faceMatchConfidence != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    attendance.hasHighConfidence ? Icons.verified : Icons.warning,
                    size: 14,
                    color: attendance.hasHighConfidence ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Match Confidence: ${(attendance.faceMatchConfidence! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: attendance.hasHighConfidence ? Colors.green.shade600 : Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _captureAttendance() async {
    // TODO: Implement camera capture and face recognition
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Feature'),
        content: const Text(
          'Face capture functionality will be implemented with:\n\n'
          '• Camera integration\n'
          '• Face detection\n'
          '• Face matching with stored profiles\n'
          '• GPS location capture\n'
          '• Automatic check-in/check-out',
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
