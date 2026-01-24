import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';
import 'project_map_screen.dart';
import 'add_project_screen.dart';
import 'edit_project_screen.dart';
import 'manage_project_users_screen.dart';
import 'package:mobile/providers/auth_provider.dart';

final projectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  return await repo.getUserProjects();
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).projects),
      ),
      floatingActionButton: (user?.role == 'owner' || user?.role == 'manager')
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProjectScreen(),
                  ),
                );
                if (result == true) {
                  ref.invalidate(projectsProvider);
                }
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).translate('add_project')),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsProvider);
        },
        child: projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context).translate('no_projects')),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectCard(project: projects[index]);
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
                Text('${AppLocalizations.of(context).error}: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(projectsProvider),
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectCard extends ConsumerWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = DateTime.parse(project.startDate);
    final endDate = DateTime.parse(project.endDate);
    final now = DateTime.now();
    final isActive = now.isAfter(startDate) && now.isBefore(endDate);
    final isCompleted = now.isAfter(endDate);
    final user = ref.watch(authStateProvider).value;
    final canManageProject = user?.role == 'owner' || user?.role == 'manager';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _ProjectDetailsDialog(project: project),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(isActive, isCompleted),
                ],
              ),

              const SizedBox(height: 16),

              // Project Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      AppLocalizations.of(context).translate('start'),
                      DateFormat('dd MMM yyyy').format(startDate),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.event,
                      AppLocalizations.of(context).translate('end'),
                      DateFormat('dd MMM yyyy').format(endDate),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // GPS Coordinates
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                      '${AppLocalizations.of(context).translate('lat_label')}: ${project.latitude.toStringAsFixed(4)}, '
                      '${AppLocalizations.of(context).translate('lng_label')}: ${project.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectMapScreen(project: project),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Map'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (canManageProject) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProjectScreen(project: project),
                            ),
                          ).then((result) {
                            if (result == true) {
                              ref.invalidate(projectsProvider);
                            }
                          });
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context, ref, project),
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, bool isCompleted) {
    Color color;
    String label;
    IconData icon;

    if (isCompleted) {
      color = AppTheme.successColor;
      label = 'COMPLETED';
      icon = Icons.check_circle;
    } else if (isActive) {
      color = AppTheme.primaryColor;
      label = 'ACTIVE';
      icon = Icons.play_circle;
    } else {
      color = AppTheme.warningColor;
      label = 'UPCOMING';
      icon = Icons.schedule;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProject(context, ref, project.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref, int projectId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('/projects/$projectId');
      
      if (context.mounted) {
        ref.invalidate(projectsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectDetailsDialog extends ConsumerWidget {
  final ProjectModel project;

  const _ProjectDetailsDialog({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final canManageProject = user?.role == 'owner' || user?.role == 'manager';
    
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.location_on, AppLocalizations.of(context).location, project.location),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              AppLocalizations.of(context).translate('start_date'),
              DateFormat('dd MMM yyyy').format(DateTime.parse(project.startDate)),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.event,
              AppLocalizations.of(context).translate('end_date'),
              DateFormat('dd MMM yyyy').format(DateTime.parse(project.endDate)),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.gps_fixed,
              AppLocalizations.of(context).translate('coordinates'),
              '${project.latitude.toStringAsFixed(6)}, ${project.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).close.toUpperCase()),
                ),
                if (canManageProject)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageProjectUsersScreen(project: project),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: Text(AppLocalizations.of(context).translate('manage_users')),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectMapScreen(project: project),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: Text(AppLocalizations.of(context).translate('view_on_map').toUpperCase()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
