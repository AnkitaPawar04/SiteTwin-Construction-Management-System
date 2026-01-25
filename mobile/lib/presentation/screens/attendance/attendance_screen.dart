import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/attendance_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/presentation/screens/attendance/face_attendance_camera_screen.dart';

final projectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  return await repo.getUserProjects();
});

// Project-aware provider that takes projectId as parameter
final todayAttendanceProvider = FutureProvider.autoDispose
    .family<AttendanceModel?, int?>((ref, projectId) async {
  if (projectId == null) {
    return null;
  }
  final repo = ref.watch(attendanceRepositoryProvider);
  return await repo.getTodayAttendanceForProject(projectId);
});

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});
  
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _isLoading = false;
  int? _selectedProjectId;
  final _locationService = LocationService();
  
  Future<Position?> _getCurrentLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
      return null;
    }
  }
  
  Future<void> _handleCheckIn() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    // Only workers and engineers can check in
    if (user?.role != 'worker' && user?.role != 'engineer') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only Workers and Engineers can mark attendance'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    if (_selectedProjectId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a project first'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Navigate to face camera screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceAttendanceCameraScreen(
          isCheckIn: true,
          projectId: _selectedProjectId!,
        ),
      ),
    );

    if (result == true && mounted) {
      // Force refresh attendance data
      ref.invalidate(todayAttendanceProvider(_selectedProjectId));
      ref.invalidate(projectsProvider);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Check-in successful! Refreshing attendance...'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _handleCheckInLegacy() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    // Only workers and engineers can check in
    if (user?.role != 'worker' && user?.role != 'engineer') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only Workers and Engineers can mark attendance'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (_selectedProjectId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a project first'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      final position = await _getCurrentLocation();
      if (position == null) return;
      
      // Get the selected project to check geofence
      final projectsAsync = ref.read(projectsProvider);
      final projects = projectsAsync.value ?? [];
      final selectedProject = projects.firstWhere(
        (p) => p.id == _selectedProjectId,
        orElse: () => ProjectModel(
          id: 0,
          name: '',
          location: '',
          latitude: 0,
          longitude: 0,
          startDate: '',
          endDate: '',
          ownerId: 0,
        ),
      );
      
      // Check if within geofence
      final geofenceCheck = _locationService.isWithinGeofence(
        position.latitude,
        position.longitude,
        selectedProject.latitude,
        selectedProject.longitude,
        selectedProject.geofenceRadiusMeters,
      );
      
      if (!geofenceCheck['is_within']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You are outside the geofence area.\nDistance from project: ${geofenceCheck['distance']}m\nAllowed radius: ${selectedProject.geofenceRadiusMeters}m',
              ),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      final repo = ref.read(attendanceRepositoryProvider);
      await repo.checkIn(
        projectId: _selectedProjectId!,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      ref.invalidate(todayAttendanceProvider(_selectedProjectId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check-in successful!\nDistance from project: ${geofenceCheck['distance']}m',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _handleCheckOut() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    // Only workers and engineers can check out
    if (user?.role != 'worker' && user?.role != 'engineer') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only Workers and Engineers can mark attendance'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    if (_selectedProjectId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a project first'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Navigate to face camera screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceAttendanceCameraScreen(
          isCheckIn: false,
          projectId: _selectedProjectId!,
        ),
      ),
    );

    if (result == true && mounted) {
      // Force refresh attendance data
      ref.invalidate(todayAttendanceProvider(_selectedProjectId));
      ref.invalidate(projectsProvider);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Check-out successful! Refreshing attendance...'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _handleCheckOutLegacy() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    // Only workers and engineers can check out
    if (user?.role != 'worker' && user?.role != 'engineer') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only Workers and Engineers can mark attendance'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final position = await _getCurrentLocation();
      if (position == null) return;
      
      final todayAttendance = await ref.read(todayAttendanceProvider(_selectedProjectId).future);
      if (todayAttendance == null) {
        throw Exception('No check-in found for today');
      }
      
      final repo = ref.read(attendanceRepositoryProvider);
      await repo.checkOut(
        attendanceId: todayAttendance.id ?? 0,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      ref.invalidate(todayAttendanceProvider(_selectedProjectId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out successful'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final canMarkAttendance = user?.role == 'worker' || user?.role == 'engineer';
    final projectsAsync = ref.watch(projectsProvider);
    
    // Auto-select first project if none selected and projects are available
    if (_selectedProjectId == null && projectsAsync.hasValue && projectsAsync.value!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedProjectId = projectsAsync.value!.first.id);
        }
      });
    }
    
    final todayAttendanceAsync = ref.watch(todayAttendanceProvider(_selectedProjectId));
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider(_selectedProjectId));
          ref.invalidate(projectsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE').format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Project Selection
              if (canMarkAttendance)
                projectsAsync.when(
                  data: (projects) {
                    if (projects.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('No projects assigned', style: TextStyle(color: Colors.grey[600])),
                        ),
                      );
                    }
                    
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedProjectId,
                          decoration: const InputDecoration(
                            labelText: 'Select Project',
                            border: OutlineInputBorder(),
                          ),
                          items: projects.map((project) {
                            return DropdownMenuItem<int>(
                              value: project.id,
                              child: Text(project.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedProjectId = value);
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading projects: $error'),
                    ),
                  ),
                ),
              
              if (canMarkAttendance) const SizedBox(height: 16),
              
              // Attendance Status Card
              todayAttendanceAsync.when(
                data: (attendance) => _buildAttendanceCard(context, attendance, canMarkAttendance),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAttendanceCard(BuildContext context, AttendanceModel? attendance, bool canMarkAttendance) {
    final hasCheckedIn = attendance != null && attendance.checkIn != null;
    final hasCheckedOut = attendance != null && attendance.checkOut != null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              hasCheckedOut
                  ? Icons.check_circle
                  : hasCheckedIn
                      ? Icons.access_time
                      : Icons.radio_button_unchecked,
              size: 64,
              color: hasCheckedOut
                  ? AppTheme.successColor
                  : hasCheckedIn
                      ? AppTheme.warningColor
                      : Colors.grey,
            ),
            const SizedBox(height: 16),
            
            Text(
              hasCheckedOut
                  ? 'Work Complete'
                  : hasCheckedIn
                      ? 'Working'
                      : 'Not Checked In',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Check-in time
            if (hasCheckedIn) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Check-in:'),
                  Text(
                    _formatTime(attendance.checkIn!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Check-out time
            if (hasCheckedOut) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Check-out:'),
                  Text(
                    _formatTime(attendance.checkOut!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Working hours
            if (hasCheckedIn && hasCheckedOut) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Hours:'),
                  Text(
                    _calculateHours(attendance.checkIn!, attendance.checkOut!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: !canMarkAttendance
                    ? null
                    : _isLoading
                        ? null
                        : hasCheckedOut
                            ? null
                            : hasCheckedIn
                                ? _handleCheckOut
                                : _handleCheckIn,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(hasCheckedIn ? Icons.logout : Icons.login),
                label: Text(
                  !canMarkAttendance
                      ? 'Attendance not required for your role'
                      : hasCheckedOut
                          ? 'Completed'
                          : hasCheckedIn
                              ? 'CHECK OUT'
                              : 'CHECK IN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: hasCheckedOut
                      ? Colors.grey
                      : hasCheckedIn
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(String isoTime) {
    final dateTime = DateTime.parse(isoTime);
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  String _calculateHours(String checkIn, String checkOut) {
    final start = DateTime.parse(checkIn);
    final end = DateTime.parse(checkOut);
    final duration = end.difference(start);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }
}
