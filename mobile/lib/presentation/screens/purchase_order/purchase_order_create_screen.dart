import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/data/models/vendor_model.dart';
import 'package:mobile/data/models/purchase_order_model.dart';
import 'package:mobile/providers/providers.dart';

/// Purchase Order Creation Screen
/// Allows Purchase Managers to create POs from material requests
/// Enforces GST/Non-GST validation rules
class PurchaseOrderCreateScreen extends ConsumerStatefulWidget {
  final MaterialRequestModel materialRequest;

  const PurchaseOrderCreateScreen({
    super.key,
    required this.materialRequest,
  });

  @override
  ConsumerState<PurchaseOrderCreateScreen> createState() =>
      _PurchaseOrderCreateScreenState();
}

class _PurchaseOrderCreateScreenState
    extends ConsumerState<PurchaseOrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  List<VendorModel> _vendors = [];
  VendorModel? _selectedVendor;
  String _selectedGSTType = AppConstants.productGST;
  DateTime _selectedDate = DateTime.now();
  
  // Item pricing - maps material_id to (unit_price, gst_rate)
  final Map<int, Map<String, double>> _itemPricing = {};

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _initializeItemPricing();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _initializeItemPricing() {
    for (var item in widget.materialRequest.items) {
      _itemPricing[item.materialId] = {
        'unit_price': 0.0,
        'gst_rate': _selectedGSTType == AppConstants.productGST ? 18.0 : 0.0,
      };
    }
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from repository
      // For now, using placeholder data
      _vendors = [
        VendorModel(
          id: 1,
          name: 'ABC Suppliers Pvt Ltd',
          contactPerson: 'Rajesh Kumar',
          phone: '9876543210',
          email: 'rajesh@abcsuppliers.com',
          gstNumber: '27AABCU9603R1ZX',
          vendorType: 'GST',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        VendorModel(
          id: 2,
          name: 'XYZ Construction Materials',
          contactPerson: 'Amit Sharma',
          phone: '9123456789',
          gstNumber: '27AACFX1234E1Z5',
          vendorType: 'GST',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        VendorModel(
          id: 3,
          name: 'Local Sand Supplier',
          contactPerson: 'Suresh',
          phone: '9999888877',
          vendorType: 'NON_GST',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load vendors: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<VendorModel> get _filteredVendors {
    // Filter vendors based on selected GST type
    if (_selectedGSTType == AppConstants.productGST) {
      return _vendors.where((v) => v.isGSTVendor).toList();
    } else {
      return _vendors.where((v) => !v.isGSTVendor).toList();
    }
  }

  double _calculateItemTotal(int materialId, int quantity) {
    final pricing = _itemPricing[materialId];
    if (pricing == null) return 0.0;
    
    final unitPrice = pricing['unit_price'] ?? 0.0;
    final gstRate = pricing['gst_rate'] ?? 0.0;
    final subtotal = unitPrice * quantity;
    final gstAmount = subtotal * (gstRate / 100);
    
    return subtotal + gstAmount;
  }

  double get _totalAmount {
    double total = 0.0;
    for (var item in widget.materialRequest.items) {
      total += _calculateItemTotal(item.materialId, item.quantity);
    }
    return total;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createPurchaseOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vendor')),
      );
      return;
    }
    
    // Validate that all items have pricing
    for (var item in widget.materialRequest.items) {
      final pricing = _itemPricing[item.materialId];
      if (pricing == null || (pricing['unit_price'] ?? 0) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter unit price for ${item.materialName ?? 'all materials'}'),
          ),
        );
        return;
      }
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Purchase Order'),
        content: Text(
          'Create PO for ₹${_totalAmount.toStringAsFixed(2)} with ${_selectedVendor!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Prepare PO items with pricing
      final items = widget.materialRequest.items.map((item) {
        final pricing = _itemPricing[item.materialId]!;
        return {
          'material_id': item.materialId,
          'quantity': item.quantity,
          'unit': item.unit ?? 'units',
          'rate': pricing['unit_price'],
          'gst_rate': pricing['gst_rate'],
        };
      }).toList();
      
      // Create PO via repository
      final repository = ref.read(purchaseOrderRepositoryProvider);
      await repository.createPurchaseOrder(
        projectId: widget.materialRequest.projectId,
        vendorId: _selectedVendor!.id,
        materialRequestId: widget.materialRequest.id,
        items: items,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase Order created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create PO: $e'),
            duration: const Duration(seconds: 5),
          ),
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
        title: const Text('Create Purchase Order'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading && _vendors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Material Request Info
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
                              const Text(
                                'Material Request Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('Project', widget.materialRequest.projectName ?? 'Unknown'),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Requested By',
                            widget.materialRequest.requestedByName ?? 'Unknown',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Request ID', '#${widget.materialRequest.id}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // GST Type Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Type *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('GST Products'),
                                  subtitle: const Text('18% GST applicable'),
                                  value: AppConstants.productGST,
                                  groupValue: _selectedGSTType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGSTType = value!;
                                      _selectedVendor = null; // Reset vendor selection
                                      // Update GST rates
                                      for (var key in _itemPricing.keys) {
                                        _itemPricing[key]!['gst_rate'] = 18.0;
                                      }
                                    });
                                  },
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Non-GST Products'),
                                  subtitle: const Text('No GST'),
                                  value: AppConstants.productNonGST,
                                  groupValue: _selectedGSTType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGSTType = value!;
                                      _selectedVendor = null; // Reset vendor selection
                                      // Update GST rates to 0
                                      for (var key in _itemPricing.keys) {
                                        _itemPricing[key]!['gst_rate'] = 0.0;
                                      }
                                    });
                                  },
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'GST and Non-GST items cannot be mixed in the same PO',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vendor Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Vendor *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<VendorModel>(
                            value: _selectedVendor,
                            decoration: InputDecoration(
                              hintText: 'Choose a vendor',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _filteredVendors.map((vendor) {
                              return DropdownMenuItem(
                                value: vendor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      vendor.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (vendor.gstNumber != null)
                                      Text(
                                        'GST: ${vendor.gstNumber}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (vendor) {
                              setState(() => _selectedVendor = vendor);
                            },
                            validator: (value) {
                              if (value == null) return 'Please select a vendor';
                              return null;
                            },
                          ),
                          if (_selectedVendor != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedVendor!.contactPerson != null)
                                    _buildVendorInfo(
                                      Icons.person,
                                      _selectedVendor!.contactPerson!,
                                    ),
                                  if (_selectedVendor!.phone != null) ...[
                                    const SizedBox(height: 4),
                                    _buildVendorInfo(Icons.phone, _selectedVendor!.phone!),
                                  ],
                                  if (_selectedVendor!.email != null) ...[
                                    const SizedBox(height: 4),
                                    _buildVendorInfo(Icons.email, _selectedVendor!.email!),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PO Date
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PO Date *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Items & Pricing
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Items & Pricing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          ...widget.materialRequest.items.map((item) {
                            return _buildItemPricingRow(item);
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Total Amount
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any special instructions or notes...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create PO Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createPurchaseOrder,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        _isLoading ? 'CREATING...' : 'CREATE PURCHASE ORDER',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildItemPricingRow(MaterialRequestItemModel item) {
    final pricing = _itemPricing[item.materialId]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.materialName ?? 'Material #${item.materialId}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quantity: ${item.quantity} ${item.unit ?? 'units'}',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: pricing['unit_price']! > 0 
                      ? pricing['unit_price']!.toString() 
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Unit Price (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      pricing['unit_price'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Invalid';
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GST: ${pricing['gst_rate']!.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ₹${_calculateItemTotal(item.materialId, item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
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
