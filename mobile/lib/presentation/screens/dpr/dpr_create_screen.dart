import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/data/models/task_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

final projectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repo = ref.watch(dprRepositoryProvider);
  return await repo.getUserProjects();
});

final myTasksForDprProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  final allTasks = await repo.getMyTasks();
  // Only show in-progress tasks for DPR creation
  return allTasks.where((task) => task.status == AppConstants.taskInProgress).toList();
});

class DprCreateScreen extends ConsumerStatefulWidget {
  final int? preSelectedTaskId;
  
  const DprCreateScreen({super.key, this.preSelectedTaskId});
  
  @override
  ConsumerState<DprCreateScreen> createState() => _DprCreateScreenState();
}

class _DprCreateScreenState extends ConsumerState<DprCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workDescriptionController = TextEditingController();
  final List<String> _photoPaths = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  int? _selectedProjectId;
  final List<int> _selectedTaskIds = []; // Changed to list for multiple selections
  
  @override
  void initState() {
    super.initState();
    // Pre-selected task will be handled after tasks load
  }
  
  // Auto-select project and task when pre-selected task is provided
  void _handlePreSelectedTask(List<TaskModel> tasks) {
    if (widget.preSelectedTaskId != null && _selectedProjectId == null) {
      final preSelectedTask = tasks.firstWhere(
        (task) => task.id == widget.preSelectedTaskId,
        orElse: () => tasks.first,
      );
      
      if (preSelectedTask.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedProjectId = preSelectedTask.projectId;
              _selectedTaskIds.add(preSelectedTask.id!);
            });
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _workDescriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    try {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
        }
        return;
      }
      
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (photo != null) {
        // Compress image
        final compressedPath = await _compressImage(photo.path);
        setState(() {
          _photoPaths.add(compressedPath);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: $e')),
        );
      }
    }
  }
  
  Future<String> _compressImage(String imagePath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    
    return result?.path ?? imagePath;
  }
  
  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
  }
  
  Future<Position?> _getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _submitDpr() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedTaskIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one task'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_photoPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('Failed to get current location');
      }
      
      final repo = ref.read(dprRepositoryProvider);
      await repo.submitDpr(
        projectId: _selectedProjectId!,
        taskIds: _selectedTaskIds, // Changed to pass list
        workDescription: _workDescriptionController.text.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
        photoPaths: _photoPaths,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DPR submitted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit DPR: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(myTasksForDprProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Daily Progress Report'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Project Selection (Primary - Must select first)
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(height: 8),
                          Text(
                            'No projects available',
                            style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedProjectId,
                          decoration: const InputDecoration(
                            labelText: 'Select Project *',
                            border: OutlineInputBorder(),
                            helperText: 'Choose the project you are working on',
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: projects.map((project) {
                            return DropdownMenuItem<int>(
                              value: project.id,
                              child: Text(
                                project.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectId = value;
                              // Clear selected tasks when project changes
                              _selectedTaskIds.clear();
                            });
                          },
                          validator: (value) {
                            if (value == null) return 'Please select a project';
                            return null;
                          },
                        ),
                      ],
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
            const SizedBox(height: 16),
            
            // Task Selection (Shows only after project is selected)
            if (_selectedProjectId == null)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please select a project first to see available tasks',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              tasksAsync.when(
              data: (tasks) {
                // Handle pre-selected task
                _handlePreSelectedTask(tasks);
                
                // Filter tasks by selected project
                final projectTasks = tasks.where((task) => task.projectId == _selectedProjectId).toList();
                
                if (projectTasks.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(height: 8),
                          Text(
                            'No in-progress tasks for this project',
                            style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start a task for this project first',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Calculate total billing amount for selected tasks
                double totalBillingAmount = 0;
                double totalWithGst = 0;
                for (var taskId in _selectedTaskIds) {
                  final task = projectTasks.firstWhere((t) => t.id == taskId, orElse: () => projectTasks.first);
                  if (task.billingAmount != null) {
                    totalBillingAmount += task.billingAmount!;
                    final gstAmount = task.billingAmount! * ((task.gstPercentage ?? 18) / 100);
                    totalWithGst += task.billingAmount! + gstAmount;
                  }
                }
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.task_alt, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Select Tasks *',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select/deselect tasks completed today (${projectTasks.length} available)',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        
                        // Task list with checkboxes
                        ...projectTasks.where((task) => task.id != null).map((task) {
                          final isSelected = _selectedTaskIds.contains(task.id!);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              task.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: task.billingAmount != null
                                ? Text(
                                    '₹${task.billingAmount!.toStringAsFixed(2)} + ${task.gstPercentage ?? 18}% GST',
                                    style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                                  )
                                : null,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true && task.id != null) {
                                  _selectedTaskIds.add(task.id!);
                                } else if (task.id != null) {
                                  _selectedTaskIds.remove(task.id!);
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                        
                        // Show total billing info if tasks selected
                        if (_selectedTaskIds.isNotEmpty && totalBillingAmount > 0) ...[
                          const Divider(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, color: Colors.green[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Invoice Value',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Base: ₹${totalBillingAmount.toStringAsFixed(2)}  |  With GST: ₹${totalWithGst.toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.green[700], fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                  child: Text('Error loading tasks: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Work Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _workDescriptionController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Describe the work completed today...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter work description';
                        }
                        if (value.trim().length < 20) {
                          return 'Description must be at least 20 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Photos Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos (${_photoPaths.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Add Photo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_photoPaths.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No photos added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    
                    if (_photoPaths.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _photoPaths.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_photoPaths[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _removePhoto(index),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitDpr,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'SUBMITTING...' : 'SUBMIT DPR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
