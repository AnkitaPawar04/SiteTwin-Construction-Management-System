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
  int? _selectedTaskId;
  
  @override
  void initState() {
    super.initState();
    _selectedTaskId = widget.preSelectedTaskId;
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
    
    if (_selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task'),
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
        taskId: _selectedTaskId,
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
            // Task Selection (Primary)
            tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(height: 8),
                          Text(
                            'No in-progress tasks available',
                            style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start a task first to submit a DPR',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Auto-select the pre-selected task or first task
                if (_selectedTaskId == null && tasks.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedTaskId = widget.preSelectedTaskId ?? tasks.first.id;
                        // Set project from selected task
                        final selectedTask = tasks.firstWhere((t) => t.id == _selectedTaskId);
                        _selectedProjectId = selectedTask.projectId;
                      });
                    }
                  });
                }
                
                final selectedTask = tasks.firstWhere(
                  (t) => t.id == _selectedTaskId,
                  orElse: () => tasks.first,
                );
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedTaskId,
                          decoration: const InputDecoration(
                            labelText: 'Select Task *',
                            border: OutlineInputBorder(),
                            helperText: 'Choose which task this report is for',
                          ),
                          items: tasks.map((task) {
                            return DropdownMenuItem<int>(
                              value: task.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (task.projectName != null)
                                    Text(
                                      task.projectName!,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedTaskId = value;
                                // Update project when task changes
                                final task = tasks.firstWhere((t) => t.id == value);
                                _selectedProjectId = task.projectId;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) return 'Please select a task';
                            return null;
                          },
                        ),
                        // Show task billing info if available
                        if (selectedTask.billingAmount != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Auto-billing enabled',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '₹${selectedTask.billingAmount!.toStringAsFixed(2)} + ${selectedTask.gstPercentage ?? 18}% GST',
                                        style: TextStyle(color: Colors.blue[700], fontSize: 11),
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
            
            // Project Selection (Auto-filled from task)
            projectsAsync.when(
              data: (projects) {
                final selectedProject = projects.firstWhere(
                  (p) => p.id == _selectedProjectId,
                  orElse: () => ProjectModel(
                    id: 0,
                    name: 'Unknown Project',
                    description: '',
                    location: '',
                    startDate: '',
                    endDate: '',
                    // status: '',
                    ownerId: 0,
                    latitude: 0,
                    longitude: 0,
                  ),
                );
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.business, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedProject.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Auto-selected from task',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
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
