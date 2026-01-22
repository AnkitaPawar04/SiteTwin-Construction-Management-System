import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_localizations.dart';
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
import 'package:mobile/presentation/screens/analytics/time_vs_cost_screen.dart';
import 'package:mobile/presentation/widgets/project_switcher.dart';
import 'package:mobile/presentation/screens/profile/profile_screen.dart';
import 'package:mobile/presentation/screens/settings/settings_screen.dart';
import 'package:mobile/presentation/widgets/connection_indicator.dart';

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
    final loc = AppLocalizations.of(context);
    
    // User should not be null when HomeScreen is shown
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_getTitle(loc, _currentIndex, user.role)),
            const SizedBox(width: 8),
            const ProjectBadge(),
          ],
        ),
        actions: [
          const ProjectSwitcher(),
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
      body: Column(
        children: [
          const ConnectionIndicator(),
          Expanded(child: _getScreensForRole(user.role)[_currentIndex]),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context, user),
    );
  }
  
  String _getTitle(AppLocalizations loc, int index, String role) {
    if (role == 'worker' || role == 'engineer') {
      switch (index) {
        case 0:
          return loc.dashboard;
        case 1:
          return loc.attendance;
        case 2:
          return loc.tasks;
        case 3:
          return loc.dailyProgress;
        default:
          return loc.dashboard;
      }
    } else {
      return loc.dashboard;
    }
  }
  
  Widget _buildDrawer(BuildContext context, dynamic user) {
    final loc = AppLocalizations.of(context);
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
            title: Text(loc.profile),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // NAVIGATION MENU - Role-based features
          
          // Dashboard - All roles
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(loc.dashboard),
            selected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          
          // Projects - All roles
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(loc.projects),
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
              title: Text(loc.attendance),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
          
          // Tasks - All roles can view tasks
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: Text(loc.tasks),
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
          
          // Assign Task - Managers and Owners
          if (user.role == 'manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: Text(loc.translate('assign_task')),
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
              title: Text(loc.dailyProgress),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
          
          if (user.role == 'manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(loc.dailyProgress),
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
          
          // Material Requests - Engineers create, Managers and Owners approve
          if (user.role == 'engineer' || user.role == 'manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(loc.materialRequests),
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
          
          // Stock & Inventory - Managers and Owners
          if (user.role == 'manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: Text(loc.translate('stock_inventory')),
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
              title: Text(loc.invoices),
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
                    // Time vs Cost Analysis - Owner only
          if (user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.analytics),
              title: Text(loc.translate('time_vs_cost')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimeVsCostScreen(),
                  ),
                );
              },
            ),
                    const Divider(),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(loc.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.logout),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(loc.translate('confirm_logout')),
                  content: Text(loc.translate('confirm_logout_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(loc.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(loc.logout),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                if (!context.mounted) return;
                Navigator.pop(context); // Close drawer first
                try {
                  await ref.read(logoutActionProvider.future);
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget? _buildBottomNavigation(BuildContext context, dynamic user) {
    final loc = AppLocalizations.of(context);
    // Worker and Engineer get four tabs (Dashboard, Attendance, Tasks, DPR)
    if (user.role == 'worker' || user.role == 'engineer') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: loc.attendance,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: loc.tasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: loc.dpr,
          ),
        ],
      );
    }
    
    // Manager and Owner: no bottom navigation (use drawer only)
    return null;
  }
}
