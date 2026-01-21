import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/providers.dart';
import 'package:mobile/data/models/dashboard_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = false;
  DashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authStateProvider).value;
      
      // Load dashboard data for owner role
      if (user?.role == 'owner') {
        final dashboardRepo = ref.read(dashboardRepositoryProvider);
        final data = await dashboardRepo.getOwnerDashboard();
        setState(() => _dashboardData = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Card(
                    color: AppTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${user?.role.toUpperCase() ?? 'USER'} Dashboard',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Grid - Show owner stats if available
                  if (user?.role == 'owner' && _dashboardData != null) ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _StatCard(
                          title: 'Projects',
                          value: '${_dashboardData!.projectsCount}',
                          icon: Icons.construction,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Invoices',
                          value: '${_dashboardData!.financialOverview.totalInvoices}',
                          icon: Icons.receipt_long,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Today Attendance',
                          value: '${_dashboardData!.attendanceSummary.todayAttendance}',
                          icon: Icons.people,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Total Workers',
                          value: '${_dashboardData!.attendanceSummary.totalWorkers}',
                          icon: Icons.person,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ] else
                    // Default statistics grid for other roles
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _StatCard(
                          title: 'Projects',
                          value: '0',
                          icon: Icons.construction,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Active Tasks',
                          value: '0',
                          icon: Icons.task_alt,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Pending DPRs',
                          value: '0',
                          icon: Icons.description,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Team Members',
                          value: '0',
                          icon: Icons.people,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Recent Activity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActivityItem(
                            icon: Icons.check_circle,
                            title: 'DPR Approved',
                            subtitle: 'Project: Commercial Plaza',
                            time: '2 hours ago',
                            color: AppTheme.successColor,
                          ),
                          const Divider(),
                          _buildActivityItem(
                            icon: Icons.add_task,
                            title: 'New Task Assigned',
                            subtitle: 'Foundation work - Phase 2',
                            time: '5 hours ago',
                            color: AppTheme.primaryColor,
                          ),
                          const Divider(),
                          _buildActivityItem(
                            icon: Icons.inventory_2,
                            title: 'Material Request',
                            subtitle: 'Cement - 100 bags',
                            time: '1 day ago',
                            color: AppTheme.warningColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
