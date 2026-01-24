import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/stock_transaction_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/material_request_model.dart';

class StockOutScreen extends StatefulWidget {
  final MaterialRequestModel? materialRequest;
  
  const StockOutScreen({
    super.key,
    this.materialRequest,
  });

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  
  int? _selectedProjectId;
  String? _selectedProjectName;
  DateTime _transactionDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();
  
  List<StockModel> _availableStock = [];
  List<_StockOutItem> _selectedItems = [];
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.materialRequest != null) {
      _selectedProjectId = widget.materialRequest!.projectId;
      _selectedProjectName = widget.materialRequest!.projectName;
      _loadStockForProject();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadStockForProject() async {
    if (_selectedProjectId == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      // final stock = await stockRepository.getStockByProject(_selectedProjectId!);
      
      // Mock data for demonstration
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _availableStock = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addStockItem(StockModel stock) {
    if (_selectedItems.any((item) => item.stock.materialId == stock.materialId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material already added')),
      );
      return;
    }

    setState(() {
      _selectedItems.add(_StockOutItem(
        stock: stock,
        quantity: 0,
        quantityController: TextEditingController(),
      ));
    });
  }

  void _removeStockItem(int index) {
    setState(() {
      _selectedItems[index].quantityController.dispose();
      _selectedItems.removeAt(index);
    });
  }

  bool _validateQuantities() {
    for (final item in _selectedItems) {
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid quantity for ${item.stock.materialName}')),
        );
        return false;
      }
      if (item.quantity > item.stock.availableQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.stock.materialName}: Requested ${item.quantity} but only ${item.stock.availableQuantity} available',
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _saveStockOut() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one material')),
      );
      return;
    }
    if (!_validateQuantities()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Stock OUT'),
        content: Text(
          'Issue ${_selectedItems.length} materials from stock?\n\n'
          'This action will reduce the available stock quantity.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      // Create stock transaction
      final transaction = StockTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID for offline
        projectId: _selectedProjectId!,
        transactionType: 'OUT',
        source: widget.materialRequest != null ? 'MATERIAL_REQUEST' : 'MANUAL',
        sourceId: widget.materialRequest?.id,
        transactionDate: DateFormat('yyyy-MM-dd').format(_transactionDate),
        items: _selectedItems.map((item) {
          return StockItemModel(
            id: DateTime.now().millisecondsSinceEpoch + item.stock.materialId,
            materialId: item.stock.materialId,
            materialName: item.stock.materialName ?? '',
            quantity: item.quantity.toDouble(),
            unit: item.stock.materialUnit ?? '',
            gstType: 'GST', // TODO: Get from material master
          );
        }).toList(),
        projectName: _selectedProjectName,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isSynced: false, // Offline queue support
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // TODO: Save to local Hive box and queue for sync
      // await stockRepository.createStockOut(transaction);
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock OUT saved. Will sync when online.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock OUT'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveStockOut,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Project Info (read-only if from material request)
                  if (widget.materialRequest != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Linked to Material Request',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Project', _selectedProjectName ?? 'N/A'),
                            _buildInfoRow('Requested By', widget.materialRequest!.requestedByName ?? 'N/A'),
                            _buildInfoRow('Request Date', _dateFormat.format(DateTime.parse(widget.materialRequest!.createdAt))),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Transaction Date
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Transaction Date'),
                      subtitle: Text(_dateFormat.format(_transactionDate)),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _transactionDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _transactionDate = picked);
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Selected Materials Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Materials to Issue (${_selectedItems.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _showMaterialSelector,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Selected Materials List
                  if (_selectedItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No materials selected',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Material" to select from available stock',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._selectedItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildStockOutItemCard(item, index);
                    }),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any remarks or special instructions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
            
            // Bottom Action Bar
            if (_selectedItems.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Items: ${_selectedItems.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Quantity: ${_selectedItems.fold<double>(0, (sum, item) => sum + item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveStockOut,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_isSaving ? 'Saving...' : 'Issue Stock'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockOutItemCard(_StockOutItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.stock.materialName ?? 'Unknown Material',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Available: ${item.stock.availableQuantity} ${item.stock.materialUnit ?? ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeStockItem(index),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to Issue',
                hintText: 'Enter quantity',
                suffixText: item.stock.materialUnit ?? '',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final qty = double.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'Invalid quantity';
                }
                if (qty > item.stock.availableQuantity) {
                  return 'Exceeds available stock';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  item.quantity = double.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialSelector() {
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Material',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // Stock List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error'))
                        : _availableStock.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    const Text('No stock available'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(20),
                                itemCount: _availableStock.length,
                                itemBuilder: (context, index) {
                                  final stock = _availableStock[index];
                                  final isSelected = _selectedItems.any(
                                    (item) => item.stock.materialId == stock.materialId,
                                  );
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(stock.materialName ?? 'Unknown'),
                                      subtitle: Text(
                                        'Available: ${stock.availableQuantity} ${stock.materialUnit ?? ''}',
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                          : const Icon(Icons.add_circle_outline),
                                      onTap: isSelected
                                          ? null
                                          : () {
                                              _addStockItem(stock);
                                              Navigator.pop(context);
                                            },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockOutItem {
  final StockModel stock;
  double quantity;
  final TextEditingController quantityController;

  _StockOutItem({
    required this.stock,
    required this.quantity,
    required this.quantityController,
  });
}
