import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/providers.dart';

/// Dialog for adding a new tool
class AddToolDialog extends ConsumerStatefulWidget {
  const AddToolDialog({super.key});

  @override
  ConsumerState<AddToolDialog> createState() => _AddToolDialogState();
}

class _AddToolDialogState extends ConsumerState<AddToolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _toolNameController = TextEditingController();
  final _toolCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCondition = 'EXCELLENT';
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _toolNameController.dispose();
    _toolCodeController.dispose();
    _categoryController.dispose();
    _purchasePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final toolRepository = ref.read(toolRepositoryProvider);
      
      await toolRepository.createTool(
        toolName: _toolNameController.text.trim(),
        toolCode: _toolCodeController.text.trim().isEmpty ? null : _toolCodeController.text.trim(),
        category: _categoryController.text.trim(),
        purchaseDate: _purchaseDate?.toIso8601String(),
        purchasePrice: _purchasePriceController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_purchasePriceController.text.trim()),
        condition: _selectedCondition,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tool added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add tool: $e')),
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
    return AlertDialog(
      title: const Text('Add New Tool'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _toolNameController,
                decoration: const InputDecoration(
                  labelText: 'Tool Name *',
                  hintText: 'e.g., Electric Drill',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tool name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _toolCodeController,
                decoration: const InputDecoration(
                  labelText: 'Tool Code (Optional)',
                  hintText: 'Auto-generated if empty',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g., Power Tools, Hand Tools',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                ),
                items: const [
                  DropdownMenuItem(value: 'EXCELLENT', child: Text('Excellent')),
                  DropdownMenuItem(value: 'GOOD', child: Text('Good')),
                  DropdownMenuItem(value: 'FAIR', child: Text('Fair')),
                  DropdownMenuItem(value: 'POOR', child: Text('Poor')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCondition = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date (Optional)',
                  ),
                  child: Text(
                    _purchaseDate == null
                        ? 'Tap to select date'
                        : DateFormat('dd MMM yyyy').format(_purchaseDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Price (Optional)',
                  hintText: 'e.g., 5000',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about the tool',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Tool'),
        ),
      ],
    );
  }
}
