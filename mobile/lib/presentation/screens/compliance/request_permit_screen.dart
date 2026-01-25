import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/providers.dart';
import '../../../data/repositories/permit_repository.dart';

class RequestPermitScreen extends ConsumerStatefulWidget {
  const RequestPermitScreen({super.key});

  @override
  ConsumerState<RequestPermitScreen> createState() => _RequestPermitScreenState();
}

class _RequestPermitScreenState extends ConsumerState<RequestPermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _safetyMeasuresController = TextEditingController();
  
  int? _selectedProjectId;
  String? _selectedTaskType;
  bool _isSubmitting = false;

  final List<Map<String, String>> _taskTypes = [
    {'value': 'HEIGHT', 'label': 'Height Work', 'icon': '🪜'},
    {'value': 'ELECTRICAL', 'label': 'Electrical Work', 'icon': '⚡'},
    {'value': 'WELDING', 'label': 'Welding Work', 'icon': '🔥'},
    {'value': 'CONFINED_SPACE', 'label': 'Confined Space', 'icon': '🚪'},
    {'value': 'HOT_WORK', 'label': 'Hot Work', 'icon': '🔧'},
    {'value': 'EXCAVATION', 'label': 'Excavation', 'icon': '⛏️'},
  ];

  final Map<String, List<String>> _suggestedSafetyMeasures = {
    'HEIGHT': [
      'Safety harness and lanyard',
      'Safety net installation',
      'Toe boards and guardrails',
      'Proper scaffolding',
      'Buddy system',
      'Tool tethering',
    ],
    'ELECTRICAL': [
      'Insulated gloves and boots',
      'Lockout/tagout procedure',
      'Voltage tester',
      'Arc flash PPE',
      'Rubber mats',
      'Fire extinguisher nearby',
    ],
    'WELDING': [
      'Welding helmet with proper shade',
      'Fire blanket',
      'Proper ventilation',
      'Fire watch personnel',
      'Spark shields',
      'Leather gloves and apron',
    ],
    'CONFINED_SPACE': [
      'Gas detector (O2, H2S, LEL)',
      'Ventilation blower',
      'Rescue tripod and harness',
      'Communication radio',
      'Entry permit',
      'Standby person outside',
    ],
    'HOT_WORK': [
      'Fire extinguisher',
      'Fire blanket',
      'Spark shields',
      'Fuel removal from area',
      'Gas monitoring',
      'Fire department notification',
    ],
    'EXCAVATION': [
      'Shoring/shielding system',
      'Ladder for access',
      'Soil testing',
      'Utility location',
      'Barrier fencing',
      'Competent person supervision',
    ],
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _safetyMeasuresController.dispose();
    super.dispose();
  }

  Future<void> _submitPermit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(permitRepositoryProvider);
      
      await repository.requestPermit(
        projectId: _selectedProjectId!,
        taskType: _selectedTaskType!,
        description: _descriptionController.text.trim(),
        safetyMeasures: _safetyMeasuresController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Permit request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addSuggestedMeasure(String measure) {
    final currentText = _safetyMeasuresController.text;
    if (currentText.isEmpty) {
      _safetyMeasuresController.text = measure;
    } else {
      _safetyMeasuresController.text = '$currentText\n$measure';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Permit'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<ProjectModel>>(
        future: ref.read(projectRepositoryProvider).getAllProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading projects: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final projects = snapshot.data ?? [];
          return _buildForm(projects);
        },
      ),
    );
  }

  Widget _buildForm(List<ProjectModel> projects) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Submit permit request for high-risk work. Safety Officer will review and approve.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Project Selection
          Text(
            'Project *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedProjectId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
              hintText: 'Select project',
            ),
            items: projects.map((project) {
              return DropdownMenuItem(
                value: project.id,
                child: Text(project.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedProjectId = value);
            },
            validator: (value) {
              if (value == null) return 'Please select a project';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Task Type Selection
          Text(
            'Task Type *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _taskTypes.map((taskType) {
              final isSelected = _selectedTaskType == taskType['value'];
              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(taskType['icon']!),
                    const SizedBox(width: 6),
                    Text(taskType['label']!),
                  ],
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedTaskType = selected ? taskType['value'] : null;
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedTaskType == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select a task type',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Work Description *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Describe the work to be performed in detail',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter work description';
              }
              if (value.trim().length < 10) {
                return 'Description must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Safety Measures
          Text(
            'Safety Measures *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _safetyMeasuresController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'List all safety measures and equipment to be used',
              prefixIcon: Icon(Icons.health_and_safety),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter safety measures';
              }
              if (value.trim().length < 10) {
                return 'Safety measures must be at least 10 characters';
              }
              return null;
            },
          ),

          // Suggested Safety Measures
          if (_selectedTaskType != null && _suggestedSafetyMeasures.containsKey(_selectedTaskType)) ...[
            const SizedBox(height: 12),
            Text(
              'Suggested Safety Measures',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestedSafetyMeasures[_selectedTaskType]!.map((measure) {
                return ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(
                    measure,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _addSuggestedMeasure(measure),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitPermit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Permit Request'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
