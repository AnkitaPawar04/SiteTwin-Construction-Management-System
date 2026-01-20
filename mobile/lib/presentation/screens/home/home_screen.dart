import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/attendance/attendance_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_screen.dart';
import 'package:mobile/presentation/screens/dpr/dpr_list_screen.dart';
import 'package:mobile/presentation/screens/material_request/material_request_list_screen.dart';
import 'package:mobile/presentation/screens/dashboard/dashboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    AttendanceScreen(),
    TaskScreen(),
    DprListScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigation(user),
    );
  }
  
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Attendance';
      case 1:
        return 'Tasks';
      case 2:
        return 'Daily Progress';
      default:
        return 'Home';
    }
  }
  
  Widget _buildDrawer(BuildContext context, dynamic user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.phone),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile
            },
          ),
          if (user.role == 'owner' || user.role == 'manager')
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
            ),
          if (user.role == 'engineer' || user.role == 'manager')
            ListTile(
              leading: const Icon(Icons.approval),
              title: const Text('Approvals'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to approvals
              },
            ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Material Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaterialRequestListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget? _buildBottomNavigation(dynamic user) {
    // Worker gets all three tabs
    if (user.role == 'worker') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'DPR',
          ),
        ],
      );
    }
    
    // Engineer/Manager gets tasks and DPR
    if (user.role == 'engineer' || user.role == 'manager') {
      return BottomNavigationBar(
        currentIndex: _currentIndex > 0 ? _currentIndex - 1 : 0,
        onTap: (index) => setState(() => _currentIndex = index + 1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'DPR',
          ),
        ],
      );
    }
    
    return null;
  }
}
