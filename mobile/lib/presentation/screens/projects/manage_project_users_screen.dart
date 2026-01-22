import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/providers/providers.dart';

final projectUsersProvider = FutureProvider.family<List<UserModel>, int>((ref, projectId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/projects/$projectId/users');
  
  final users = (response.data['data'] as List)
      .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
      .toList();
  return users;
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/users');
  
  final users = (response.data['data'] as List)
      .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
      .toList();
  return users;
});

class ManageProjectUsersScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ManageProjectUsersScreen({super.key, required this.project});

  @override
  ConsumerState<ManageProjectUsersScreen> createState() => _ManageProjectUsersScreenState();
}

class _ManageProjectUsersScreenState extends ConsumerState<ManageProjectUsersScreen> {
  bool _isLoading = false;

  Future<void> _addUser(UserModel user) async {
    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        '/projects/${widget.project.id}/assign-user',
        data: {'user_id': user.id},
      );

      if (mounted) {
        ref.invalidate(projectUsersProvider(widget.project.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} added to project'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeUser(UserModel user) async {
    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('/projects/${widget.project.id}/users/${user.id}');

      if (mounted) {
        ref.invalidate(projectUsersProvider(widget.project.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} removed from project'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final projectUsersAsync = ref.watch(projectUsersProvider(widget.project.id));
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('manage_users')} - ${widget.project.name}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Users Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('project_users'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  projectUsersAsync.when(
                    data: (users) {
                      if (users.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              loc.translate('no_users_assigned'),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isOwner = user.id == widget.project.ownerId;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name[0].toUpperCase()),
                              ),
                              title: Text(user.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${user.phone} • ${user.role}'),
                                  if (isOwner)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Project Owner',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: isOwner
                                  ? Chip(
                                      label: Text(loc.translate('owner')),
                                      backgroundColor: Colors.blue,
                                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: _isLoading ? null : () => _removeUser(user),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Available Users Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('add_users_to_project'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  projectUsersAsync.when(
                    data: (projectUsers) {
                      return allUsersAsync.when(
                        data: (allUsers) {
                          final availableUsers = allUsers
                              .where((user) => !projectUsers.any((u) => u.id == user.id))
                              .toList();

                          if (availableUsers.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  loc.translate('all_users_assigned'),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: availableUsers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final user = availableUsers[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user.name[0].toUpperCase()),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text('${user.phone} • ${user.role}'),
                                  trailing: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : () => _addUser(user),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add'),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text('Error: $error'),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
