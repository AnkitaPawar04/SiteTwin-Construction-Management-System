import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/data/models/project_model.dart';
import 'package:mobile/providers/providers.dart';

class MaterialRequestCreateScreen extends ConsumerStatefulWidget {
  const MaterialRequestCreateScreen({super.key});

  @override
  ConsumerState<MaterialRequestCreateScreen> createState() =>
      _MaterialRequestCreateScreenState();
}

class _MaterialRequestCreateScreenState
    extends ConsumerState<MaterialRequestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  List<ProjectModel> _projects = [];
  List<MaterialModel> _materials = [];
  ProjectModel? _selectedProject;
  final List<_MaterialRequestItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load projects (using DPR repository to get user's projects)
      final dprRepo = ref.read(dprRepositoryProvider);
      _projects = await dprRepo.getUserProjects();

      // Load materials
      final materialRepo = ref.read(materialRequestRepositoryProvider);
      _materials = await materialRepo.getAllMaterials();

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addItem() {
    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No materials available')),
      );
      return;
    }

    setState(() {
      _items.add(_MaterialRequestItem(material: _materials.first, quantity: 1));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = _items
          .map((item) => {
                'material_id': item.material.id,
                'quantity': item.quantity,
              })
          .toList();

      await ref.read(materialRequestRepositoryProvider).createRequest(
            projectId: _selectedProject!.id,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            items: items,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material request submitted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Material Request'),
      ),
      body: _isLoading && _materials.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Project',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<ProjectModel>(
                            initialValue: _selectedProject,
                            decoration: const InputDecoration(
                              labelText: 'Select Project',
                              border: OutlineInputBorder(),
                            ),
                            items: _projects
                                .map((project) => DropdownMenuItem(
                                      value: project,
                                      child: Text(project.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedProject = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a project';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter any additional details...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Materials',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add_circle),
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_items.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No items added yet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          else
                            ..._items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _buildItemRow(index, item);
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Request'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildItemRow(int index, _MaterialRequestItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<MaterialModel>(
                  initialValue: item.material,
                  decoration: const InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _materials
                      .map((material) => DropdownMenuItem(
                            value: material,
                            child: Text(material.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _items[index] = _MaterialRequestItem(
                          material: value,
                          quantity: item.quantity,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete),
                color: AppTheme.errorColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantity (${item.material.unit})',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final quantity = double.tryParse(value) ?? item.quantity;
                    _items[index] = _MaterialRequestItem(
                      material: item.material,
                      quantity: quantity,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${(item.material.unitPrice * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialRequestItem {
  final MaterialModel material;
  final double quantity;

  _MaterialRequestItem({
    required this.material,
    required this.quantity,
  });
}
