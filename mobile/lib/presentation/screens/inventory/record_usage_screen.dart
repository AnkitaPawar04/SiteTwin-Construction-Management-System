import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/stock_model.dart';
import 'package:mobile/providers/providers.dart';

class RecordUsageScreen extends ConsumerStatefulWidget {
  const RecordUsageScreen({super.key});

  @override
  ConsumerState<RecordUsageScreen> createState() => _RecordUsageScreenState();
}

class _RecordUsageScreenState extends ConsumerState<RecordUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  int? _selectedProjectId;
  int? _selectedMaterialId;
  final _quantityController = TextEditingController();
  
  List<StockModel> _allStock = [];
  bool _isFetchingStock = true;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    try {
      final repo = ref.read(stockRepositoryProvider);
      _allStock = await repo.getAllStock();
      setState(() {
        _isFetchingStock = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitUsage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null || _selectedMaterialId == null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(stockRepositoryProvider);
      
      await repo.removeStock(
        projectId: _selectedProjectId!,
        materialId: _selectedMaterialId!,
        quantity: double.parse(_quantityController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material usage recorded successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record usage: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique list of projects from available stock
    final projectMap = <int, String?>{};
    for (var s in _allStock) {
      projectMap[s.projectId] = s.projectName;
    }
    final projects = projectMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
    
    // Filtered unique materials based on selected project
    final materialMap = <int, StockModel>{};
    if (_selectedProjectId != null) {
      for (var s in _allStock) {
        if (s.projectId == _selectedProjectId) {
          materialMap[s.materialId] = s;
        }
      }
    }
    final materials = materialMap.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Record Material Usage')),
      body: _isFetchingStock 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Project', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedProjectId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: projects.map((p) => DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['name']?.toString() ?? 'Project #${p['id']}'),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedProjectId = val;
                          _selectedMaterialId = null; // Reset material when project changes
                        });
                      },
                      validator: (val) => val == null ? 'Please select a project' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Select Material', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedMaterialId,
                      disabledHint: const Text('Select a project first'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: materials.map((m) => DropdownMenuItem<int>(
                        value: m.materialId,
                        child: Text('${m.materialName} (Available: ${m.availableQuantity} ${m.materialUnit})'),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMaterialId = val;
                        });
                      },
                      validator: (val) => val == null ? 'Please select a material' : null,
                    ),
                    const SizedBox(height: 24),

                    const Text('Quantity Used', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      decoration: const InputDecoration(
                        hintText: 'Enter quantity used',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter quantity';
                        final numVal = double.tryParse(val);
                        if (numVal == null || numVal <= 0) return 'Enter valid quantity';
                        
                        // Check if we have enough stock
                        if (_selectedMaterialId != null) {
                          final stock = materials.firstWhere((m) => m.materialId == _selectedMaterialId);
                          if (numVal > stock.availableQuantity) {
                            return 'Insufficient stock (Available: ${stock.availableQuantity})';
                          }
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitUsage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SUBMIT STOCK OUT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
