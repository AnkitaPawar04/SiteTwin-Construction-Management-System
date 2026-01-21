import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/attendance/attendance_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_assignment_screen.dart';
import 'package:mobile/presentation/screens/dpr/dpr_list_screen.dart';
import 'package:mobile/presentation/screens/material_request/material_request_list_screen.dart';
import 'package:mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
import 'package:mobile/presentation/screens/projects/projects_screen.dart';
import 'package:mobile/presentation/screens/inventory/stock_inventory_screen.dart';
import 'package:mobile/presentation/screens/invoices/invoices_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  // Dynamic screens list based on user role
  List<Widget> _getScreensForRole(String role) {
    if (role == 'worker' || role == 'engineer') {
      return const [
        DashboardScreen(),
        AttendanceScreen(),
        TaskScreen(),
        DprListScreen(),
      ];
    } else {
      // Manager and Owner - Dashboard only in main view
      return const [
        DashboardScreen(),
      ];
    }
  }
  
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
        title: Text(_getTitle(_currentIndex, user.role)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: _getScreensForRole(user.role)[_currentIndex],
      bottomNavigationBar: _buildBottomNavigation(user),
    );
  }
  
  String _getTitle(int index, String role) {
    if (role == 'worker' || role == 'engineer') {
      switch (index) {
        case 0:
          return 'Dashboard';
        case 1:
          return 'Attendance';
        case 2:
          return 'Tasks';
        case 3:
          return 'Daily Progress';
        default:
          return 'Home';
      }
    } else {
      return 'Dashboard';
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
          
          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile screen - Coming soon')),
              );
            },
          ),
          
          const Divider(),
          
          // NAVIGATION MENU - Role-based features
          
          // Dashboard - All roles
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          
          // Projects - All roles
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectsScreen(),
                ),
              );
            },
          ),
          
          // Attendance - Workers & Engineers only
          if (user.role == 'worker' || user.role == 'engineer')
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Attendance'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
          
          // Tasks - All roles can view tasks
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text('Tasks'),
            selected: _currentIndex == 2 && (user.role == 'worker' || user.role == 'engineer'),
            onTap: () {
              Navigator.pop(context);
              if (user.role == 'worker' || user.role == 'engineer') {
                setState(() => _currentIndex = 2);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskScreen(),
                  ),
                );
              }
            },
          ),
          
          // Assign Task - Managers only
          if (user.role == 'manager')
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Assign Task'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskAssignmentScreen(),
                  ),
                );
              },
            ),
          
          // DPR - Workers & Engineers submit, Managers approve
          if (user.role == 'worker' || user.role == 'engineer')
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Daily Progress Reports'),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
          
          if (user.role == 'manager')
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('DPR Approvals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DprListScreen(),
                  ),
                );
              },
            ),
          
          // Material Requests - Engineers create, Managers approve
          if (user.role == 'engineer' || user.role == 'manager')
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
          
          // Stock & Inventory - Managers only
          if (user.role == 'manager')
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Stock & Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockInventoryScreen(),
                  ),
                );
              },
            ),
          
          // Invoices - Owner only
          if (user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('GST Invoices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoicesScreen(),
                  ),
                );
              },
            ),
          
          const Divider(),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming soon')),
              );
            },
          ),
          
          // Logout
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
                await ref.read(logoutActionProvider.future);
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
    // Worker and Engineer get four tabs (Dashboard, Attendance, Tasks, DPR)
    if (user.role == 'worker' || user.role == 'engineer') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
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
    
    // Manager and Owner: no bottom navigation (use drawer only)
    return null;
  }
}
