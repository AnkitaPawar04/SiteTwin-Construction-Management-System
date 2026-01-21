import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock notification data
    final mockNotifications = [
      {
        'id': 1,
        'title': 'New Task Assigned',
        'message': 'You have been assigned a new task: Install electrical wiring',
        'type': 'task',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'id': 2,
        'title': 'DPR Approved',
        'message': 'Your daily progress report for Jan 20 has been approved',
        'type': 'approval',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': false,
      },
      {
        'id': 3,
        'title': 'Material Request Updated',
        'message': 'Your material request #MR-025 has been approved by manager',
        'type': 'material',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
      },
      {
        'id': 4,
        'title': 'Attendance Reminder',
        'message': 'Don\'t forget to mark your check-out for today',
        'type': 'reminder',
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        'isRead': true,
      },
      {
        'id': 5,
        'title': 'Task Completed',
        'message': 'Worker completed task: Foundation excavation',
        'type': 'task',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marked all as read')),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
          final isRead = notification['isRead'] as bool;
          final time = notification['time'] as DateTime;

          return Card(
            color: isRead ? null : AppTheme.primaryColor.withValues(alpha: 0.05),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTypeColor(notification['type'] as String)
                    .withValues(alpha: 0.1),
                child: Icon(
                  _getTypeIcon(notification['type'] as String),
                  color: _getTypeColor(notification['type'] as String),
                ),
              ),
              title: Text(
                notification['title'] as String,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification['message'] as String),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: !isRead
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                // Mark as read and show details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(notification['message'] as String),
                    action: SnackBarAction(
                      label: 'VIEW',
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'task':
        return AppTheme.primaryColor;
      case 'approval':
        return AppTheme.successColor;
      case 'material':
        return AppTheme.warningColor;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.task_alt;
      case 'approval':
        return Icons.check_circle;
      case 'material':
        return Icons.inventory_2;
      case 'reminder':
        return Icons.notifications_active;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM, hh:mm a').format(time);
    }
  }
}
