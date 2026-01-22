import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

class TimeVsCostScreen extends ConsumerStatefulWidget {
  const TimeVsCostScreen({super.key});

  @override
  ConsumerState<TimeVsCostScreen> createState() => _TimeVsCostScreenState();
}

class _TimeVsCostScreenState extends ConsumerState<TimeVsCostScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _timeVsCostData;

  @override
  void initState() {
    super.initState();
    _loadTimeVsCostData();
  }

  Future<void> _loadTimeVsCostData() async {
    setState(() => _isLoading = true);
    
    try {
      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      final data = await dashboardRepo.getTimeVsCostData();
      setState(() => _timeVsCostData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load time vs cost data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time vs Cost Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimeVsCostData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTimeVsCostData,
              child: _timeVsCostData == null
                  ? const Center(child: Text('No data available'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildOverallSummaryCard(),
                        const SizedBox(height: 16),
                        _buildTimeProgressCard(),
                        const SizedBox(height: 16),
                        _buildCostProgressCard(),
                        const SizedBox(height: 16),
                        _buildProjectsList(),
                      ],
                    ),
            ),
    );
  }

  Widget _buildOverallSummaryCard() {
    final totalProjects = _timeVsCostData!['total_projects'] ?? 0;
    final overallProgress = _timeVsCostData!['overall_progress'] ?? 0;
    final costUtilization = _timeVsCostData!['cost_utilization_rate'] ?? 0;

    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Overall Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Projects', totalProjects.toString(), Icons.business),
                _buildSummaryItem('Time Progress', '$overallProgress%', Icons.access_time),
                _buildSummaryItem('Cost Used', '$costUtilization%', Icons.attach_money),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeProgressCard() {
    final totalPlannedDays = _timeVsCostData!['total_planned_days'] ?? 0;
    final totalElapsedDays = _timeVsCostData!['total_elapsed_days'] ?? 0;
    final overallProgress = (_timeVsCostData!['overall_progress'] ?? 0.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Time Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                overallProgress > 90 ? Colors.red : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressDetail(
                  'Planned Days',
                  totalPlannedDays.toString(),
                  Icons.calendar_month,
                ),
                _buildProgressDetail(
                  'Elapsed Days',
                  totalElapsedDays.toString(),
                  Icons.hourglass_bottom,
                ),
                _buildProgressDetail(
                  'Progress',
                  '${overallProgress.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostProgressCard() {
    final totalBudget = _timeVsCostData!['total_budget'] ?? 0;
    final totalSpent = _timeVsCostData!['total_spent'] ?? 0;
    final totalRemaining = _timeVsCostData!['total_remaining'] ?? 0;
    final costUtilization = (_timeVsCostData!['cost_utilization_rate'] ?? 0.0).toDouble();

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppTheme.successColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Cost Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: costUtilization / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                costUtilization > 90 ? Colors.orange : AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCostDetail(
                  'Total Budget',
                  currencyFormat.format(totalBudget),
                  Icons.account_balance,
                  Colors.blue,
                ),
                _buildCostDetail(
                  'Spent',
                  currencyFormat.format(totalSpent),
                  Icons.money_off,
                  Colors.orange,
                ),
                _buildCostDetail(
                  'Remaining',
                  currencyFormat.format(totalRemaining),
                  Icons.savings,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCostDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProjectsList() {
    final projectsAnalysis = _timeVsCostData!['projects_analysis'] as List<dynamic>? ?? [];

    if (projectsAnalysis.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No project data available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Projects Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...projectsAnalysis.map((project) => _buildProjectItem(project)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    final progressPercentage = (project['progress_percentage'] ?? 0.0).toDouble();
    final totalBudget = project['total_budget'] ?? 0;
    final spentAmount = project['spent_amount'] ?? 0;
    final plannedDays = project['planned_days'] ?? 0;
    final elapsedDays = project['elapsed_days'] ?? 0;

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Project #${project['project_id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(progressPercentage).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _getProgressColor(progressPercentage),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progressPercentage),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$elapsedDays / $plannedDays days',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                      'Cost',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currencyFormat.format(spentAmount)} / ${currencyFormat.format(totalBudget)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 50) {
      return Colors.green;
    } else if (progress < 75) {
      return Colors.blue;
    } else if (progress < 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
