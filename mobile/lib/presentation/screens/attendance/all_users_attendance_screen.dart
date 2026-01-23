import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/providers.dart';

final projectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  return await repo.getUserProjects();
});

final ownerAttendanceProvider = FutureProvider.autoDispose<List<AttendanceModel>>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  
  try {
    return await repo.getAllAttendance();
  } catch (e) {
    return [];
  }
});

final userAttendanceProvider = FutureProvider.autoDispose<List<AttendanceModel>>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  
  try {
    return await repo.getMyAttendance();
  } catch (e) {
    return [];
  }
});

final allAttendanceProvider =
    FutureProvider.autoDispose.family<List<AttendanceModel>, Map<String, dynamic>>(
  (ref, filters) async {
    final repo = ref.watch(attendanceRepositoryProvider);
    final authState = ref.watch(authStateProvider);
    
    try {
      // Get user info
      final user = authState.value;
      
      // If user is owner, fetch all attendance records
      if (user != null && user.isOwner) {
        return await repo.getAllAttendance();
      }
      
      // Otherwise fetch user's own attendance
      final all = await repo.getMyAttendance();
      return all;
    } catch (e) {
      return [];
    }
  },
);

class AllUsersAttendanceScreen extends ConsumerStatefulWidget {
  const AllUsersAttendanceScreen({super.key});

  @override
  ConsumerState<AllUsersAttendanceScreen> createState() =>
      _AllUsersAttendanceScreenState();
}

class _AllUsersAttendanceScreenState extends ConsumerState<AllUsersAttendanceScreen> {
  int? _selectedProjectId;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    // Use owner provider for owners, user provider for others
    final attendance = user?.isOwner == true 
        ? ref.watch(ownerAttendanceProvider)
        : ref.watch(userAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Attendance'),
      ),
      body: Column(
        children: [
          // Filter Section - show for everyone
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Project Filter - show for everyone
                projects.when(
                  data: (projectList) => DropdownButtonFormField<int?>(
                    decoration: InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    initialValue: _selectedProjectId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Projects'),
                      ),
                      ...projectList.map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedProjectId = value);
                    },
                  ),
                  loading: () => const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 56,
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
                const SizedBox(height: 12),
                // Date Filter
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                          : 'Select date',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Clear Filters Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedProjectId = null;
                      _selectedDate = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                ),
              ],
            ),
          ),
          // Attendance List
          Expanded(
            child: attendance.when(
              data: (attendanceList) {
                if (attendanceList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter attendance by project and date
                final filtered = attendanceList.where((record) {
                  // Filter by project
                  if (_selectedProjectId != null && record.projectId != _selectedProjectId) {
                    return false;
                  }
                  // Filter by date - compare as DateTime objects
                  if (_selectedDate != null) {
                    try {
                      // Parse record.date (format: YYYY-MM-DD)
                      final recordDateTime = DateTime.parse(record.date);
                      // Create a DateTime for selected date at midnight
                      final selectedDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                      // Compare just the date part (ignoring time)
                      if (recordDateTime.year != selectedDateTime.year ||
                          recordDateTime.month != selectedDateTime.month ||
                          recordDateTime.day != selectedDateTime.day) {
                        return false;
                      }
                    } catch (e) {
                      // If parsing fails, skip this record
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No records match the filters',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group attendance by userId
                final groupedByUser = <int, List<AttendanceModel>>{};
                for (var record in filtered) {
                  groupedByUser.putIfAbsent(record.userId, () => []);
                  groupedByUser[record.userId]!.add(record);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedByUser.keys.length,
                  itemBuilder: (context, index) {
                    final userId = groupedByUser.keys.elementAt(index);
                    final userAttendance = groupedByUser[userId]!;
                    // Get user name from first record (should be same for all records of same user)
                    final userName = userAttendance.first.userName ?? 'User #$userId';

                    return _buildUserAttendanceCard(userName, userAttendance);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAttendanceCard(
    String userName,
    List<AttendanceModel> userAttendance,
  ) {
    // Sort by date, most recent first
    userAttendance.sort((a, b) => b.date.compareTo(a.date));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Records: ${userAttendance.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                ...userAttendance.map((attendance) {
                  final checkInTime = attendance.checkIn != null
                      ? DateTime.parse(attendance.checkIn!).toLocal()
                      : null;
                  final checkOutTime = attendance.checkOut != null
                      ? DateTime.parse(attendance.checkOut!).toLocal()
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Checked In',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  DateTime.parse(attendance.date),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (checkInTime != null)
                                Text(
                                  'Check-in: ${DateFormat('HH:mm').format(checkInTime)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (checkOutTime != null)
                                Text(
                                  'Check-out: ${DateFormat('HH:mm').format(checkOutTime)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
