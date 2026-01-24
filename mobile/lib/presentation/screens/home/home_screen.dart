import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/presentation/screens/attendance/attendance_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_assignment_screen.dart';
import 'package:mobile/presentation/screens/dpr/dpr_list_screen.dart';
import 'package:mobile/presentation/screens/material_request/material_request_list_screen.dart';
import 'package:mobile/presentation/screens/material_request/material_request_create_screen.dart';
import 'package:mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/presentation/screens/projects/projects_screen.dart';
import 'package:mobile/presentation/screens/inventory/stock_inventory_screen.dart';
import 'package:mobile/presentation/screens/stock/stock_in_screen.dart';
import 'package:mobile/presentation/screens/stock/stock_out_screen.dart';
import 'package:mobile/presentation/screens/purchase_order/purchase_order_list_screen.dart';
import 'package:mobile/presentation/screens/analytics/cost_dashboard_screen.dart';
import 'package:mobile/presentation/screens/analytics/consumption_variance_screen.dart';
import 'package:mobile/presentation/screens/analytics/unit_costing_screen.dart';
import 'package:mobile/presentation/screens/profile/profile_screen.dart';
import 'package:mobile/presentation/screens/settings/settings_screen.dart';
import 'package:mobile/presentation/widgets/connection_indicator.dart';
import 'package:mobile/presentation/widgets/global_sync_indicator.dart';
import 'package:mobile/presentation/screens/admin/user_management_screen.dart';
import 'package:mobile/presentation/screens/attendance/all_users_attendance_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  // Dynamic screens list based on user role
  List<Widget> _getScreensForRole(String role) {
    // Worker: Dashboard, Attendance
    if (role == 'worker') {
      return const [
        DashboardScreen(),
        AttendanceScreen(),
      ];
    } 
    // Site Engineer: Dashboard, Attendance, Material Requests, Tasks
    else if (role == 'engineer' || role == 'site_engineer') {
      return const [
        DashboardScreen(),
        AttendanceScreen(),
        MaterialRequestListScreen(),
        TaskScreen(),
      ];
    }
    // Purchase Manager: Dashboard, Material Requests, Stock
    else if (role == 'purchase_manager') {
      return const [
        DashboardScreen(),
        MaterialRequestListScreen(),
        StockInventoryScreen(),
      ];
    }
    // Project Manager: Dashboard, Tasks, DPR Review
    else if (role == 'manager' || role == 'project_manager') {
      return const [
        DashboardScreen(),
        TaskScreen(),
        DprListScreen(),
      ];
    }
    // Safety Officer: Dashboard, Attendance
    else if (role == 'safety_officer') {
      return const [
        DashboardScreen(),
        AllUsersAttendanceScreen(),
      ];
    }
    // Owner: Dashboard only (uses drawer for all features)
    else {
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
        title: Text(_getTitle(loc, _currentIndex, user.role)),
      ),
      drawer: _buildDrawer(context, user),
      body: Column(
        children: [
          const ConnectionIndicator(),
          const GlobalSyncIndicator(),
          Expanded(child: _getScreensForRole(user.role)[_currentIndex]),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context, user),
      floatingActionButton: _buildFloatingActionButton(context, user),
    );
  }
  
  String _getTitle(AppLocalizations loc, int index, String role) {
    // Worker
    if (role == 'worker') {
      switch (index) {
        case 0: return loc.dashboard;
        case 1: return loc.attendance;
        default: return loc.dashboard;
      }
    }
    // Site Engineer
    else if (role == 'engineer' || role == 'site_engineer') {
      switch (index) {
        case 0: return loc.dashboard;
        case 1: return loc.attendance;
        case 2: return loc.materialRequests;
        case 3: return loc.tasks;
        default: return loc.dashboard;
      }
    }
    // Purchase Manager
    else if (role == 'purchase_manager') {
      switch (index) {
        case 0: return loc.dashboard;
        case 1: return loc.materialRequests;
        case 2: return loc.translate('stock_inventory');
        default: return loc.dashboard;
      }
    }
    // Project Manager
    else if (role == 'manager' || role == 'project_manager') {
      switch (index) {
        case 0: return loc.dashboard;
        case 1: return loc.tasks;
        case 2: return loc.dailyProgress;
        default: return loc.dashboard;
      }
    }
    // Safety Officer
    else if (role == 'safety_officer') {
      switch (index) {
        case 0: return loc.dashboard;
        case 1: return 'Team Attendance';
        default: return loc.dashboard;
      }
    }
    // Owner
    else {
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
          
          // Attendance - Workers & Site Engineers only
          if (user.role == 'worker' || user.role == 'engineer' || user.role == 'site_engineer')
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(loc.attendance),
              selected: _currentIndex == 1 && (user.role == 'worker' || user.role == 'engineer' || user.role == 'site_engineer'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
          
          // Material Requests - Site Engineers create, Purchase Managers review
          if (user.role == 'engineer' || user.role == 'site_engineer' || user.role == 'purchase_manager')
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(loc.materialRequests),
              selected: (user.role == 'engineer' || user.role == 'site_engineer') && _currentIndex == 2 ||
                        user.role == 'purchase_manager' && _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                if (user.role == 'engineer' || user.role == 'site_engineer') {
                  setState(() => _currentIndex = 2);
                } else if (user.role == 'purchase_manager') {
                  setState(() => _currentIndex = 1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaterialRequestListScreen(),
                    ),
                  );
                }
              },
            ),
          
          // Tasks - Site Engineers, Project Managers
          if (user.role == 'engineer' || user.role == 'site_engineer' || user.role == 'manager' || user.role == 'project_manager')
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: Text(loc.tasks),
              selected: (user.role == 'engineer' || user.role == 'site_engineer') && _currentIndex == 3 ||
                        (user.role == 'manager' || user.role == 'project_manager') && _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                if (user.role == 'engineer' || user.role == 'site_engineer') {
                  setState(() => _currentIndex = 3);
                } else if (user.role == 'manager' || user.role == 'project_manager') {
                  setState(() => _currentIndex = 1);
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
          
          // Assign Task - Project Managers only
          if (user.role == 'manager' || user.role == 'project_manager')
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
          
          // DPR - Project Managers and Owners review only (no creation from app)
          if (user.role == 'manager' || user.role == 'project_manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(loc.dailyProgress),
              selected: (user.role == 'manager' || user.role == 'project_manager') && _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                if (user.role == 'manager' || user.role == 'project_manager') {
                  setState(() => _currentIndex = 2);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(loc.dailyProgress),
                        ),
                        body: const DprListScreen(),
                      ),
                    ),
                  );
                }
              },
            ),
          
          // Stock & Inventory - Purchase Managers, Project Managers, Owners
          if (user.role == 'purchase_manager' || user.role == 'manager' || user.role == 'project_manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: Text(loc.translate('stock_inventory')),
              selected: user.role == 'purchase_manager' && _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                if (user.role == 'purchase_manager') {
                  setState(() => _currentIndex = 2);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockInventoryScreen(),
                    ),
                  );
                }
              },
            ),
          
          // Stock IN - Purchase Managers, Owners (view only)
          if (user.role == 'purchase_manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Stock IN'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockInScreen(),
                  ),
                );
              },
            ),
          
          // Stock OUT - Purchase Managers only
          if (user.role == 'purchase_manager')
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Stock OUT'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockOutScreen(),
                  ),
                );
              },
            ),
          
          // Purchase Orders - Purchase Managers, Owners
          if (user.role == 'purchase_manager' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Purchase Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseOrderListScreen(),
                  ),
                );
              },
            ),
          
          const Divider(),
          
          // Cost Analytics Section - Owners and Project Managers
          if (user.role == 'owner' || user.role == 'manager' || user.role == 'project_manager')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Cost Analytics',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          
          // Cost Dashboard - Owners and Project Managers
          if (user.role == 'owner' || user.role == 'manager' || user.role == 'project_manager')
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Cost Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CostDashboardScreen(),
                  ),
                );
              },
            ),
          
          // Consumption Variance - Owners and Project Managers
          if (user.role == 'owner' || user.role == 'manager' || user.role == 'project_manager')
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Consumption Variance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConsumptionVarianceScreen(),
                  ),
                );
              },
            ),
          
          // Unit Costing - Owners and Project Managers
          if (user.role == 'owner' || user.role == 'manager' || user.role == 'project_manager')
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text('Unit Costing'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnitCostingScreen(),
                  ),
                );
              },
            ),
          
          const Divider(),
          
          // Team Attendance - Safety Officers, Owners
          if (user.role == 'safety_officer' || user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.groups),
              title: Text(loc.teamAttendance),
              selected: user.role == 'safety_officer' && _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                if (user.role == 'safety_officer') {
                  setState(() => _currentIndex = 1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllUsersAttendanceScreen(),
                    ),
                  );
                }
              },
            ),
          
          // User Management - Owners only
          if (user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(loc.translate('user_management')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
            ),
          
          // User Management - Owner only
          if (user.role == 'owner')
            ListTile(
              leading: const Icon(Icons.people_alt),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
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
                  // Show loading indicator
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logging out...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  
                  await ref.read(logoutActionProvider.future);
                  
                  // Wait to ensure everything is cleared
                  await Future.delayed(const Duration(milliseconds: 300));
                  
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
    
    // Worker: Dashboard, Attendance
    if (user.role == 'worker') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: loc.attendance,
          ),
        ],
      );
    }
    
    // Site Engineer: Dashboard, Attendance, Material Requests, Tasks
    else if (user.role == 'engineer' || user.role == 'site_engineer') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: loc.attendance,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: loc.materialRequests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_alt),
            label: loc.tasks,
          ),
        ],
      );
    }
    
    // Purchase Manager: Dashboard, Material Requests, Stock
    else if (user.role == 'purchase_manager') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: loc.materialRequests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warehouse),
            label: loc.translate('stock_inventory'),
          ),
        ],
      );
    }
    
    // Project Manager: Dashboard, Tasks, DPR
    else if (user.role == 'manager' || user.role == 'project_manager') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_alt),
            label: loc.tasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description),
            label: loc.dailyProgress,
          ),
        ],
      );
    }
    
    // Safety Officer: Dashboard, Team Attendance
    else if (user.role == 'safety_officer') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups),
            label: loc.teamAttendance,
          ),
        ],
      );
    }
    
    // Owner: No bottom navigation - uses drawer only
    return null;
  }
  
  Widget? _buildFloatingActionButton(BuildContext context, dynamic user) {
    final loc = AppLocalizations.of(context);
    
    // Site Engineer on Material Requests screen (index 2): "New Request" button
    if ((user.role == 'engineer' || user.role == 'site_engineer') && _currentIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MaterialRequestCreateScreen(),
            ),
          );
          // Refresh list if request was created
          if (result == true && mounted) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: Text(loc.translate('new_request')),
      );
    }
    
    return null;
  }
}
