import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/material_request_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';

class MaterialRequestReceiveScreen extends ConsumerStatefulWidget {
  final MaterialRequestModel materialRequest;

  const MaterialRequestReceiveScreen({
    super.key,
    required this.materialRequest,
  });

  @override
  ConsumerState<MaterialRequestReceiveScreen> createState() =>
      _MaterialRequestReceiveScreenState();
}

class _MaterialRequestReceiveScreenState
    extends ConsumerState<MaterialRequestReceiveScreen> {
  bool _isLoading = false;
  late final Map<int, int> _receivedQuantities;
  late final Map<int, TextEditingController> _quantityControllers;

  @override
  void initState() {
    super.initState();
    _receivedQuantities = {};
    _quantityControllers = {};
    
    for (var item in widget.materialRequest.items) {
      _receivedQuantities[item.id] = item.quantity;
      _quantityControllers[item.id] = TextEditingController(
        text: item.quantity.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReception() async {
    // Update received quantities from controllers
    for (var item in widget.materialRequest.items) {
      final value = int.tryParse(_quantityControllers[item.id]?.text ?? '0');
      if (value != null) {
        _receivedQuantities[item.id] = value;
      }
    }

    // Validate reception
    bool hasValue = false;
    for (var item in widget.materialRequest.items) {
      final received = _receivedQuantities[item.id] ?? 0;
      if (received < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Received quantity cannot be negative'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      if (received > 0) hasValue = true;
    }

    if (!hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one received quantity'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Material Arrival'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Have these materials physically arrived on site?'),
            const SizedBox(height: 16),
            const Text(
              'Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.materialRequest.items.map((item) {
              final received = _receivedQuantities[item.id] ?? 0;
              if (received <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '${item.materialName ?? 'Material'}: $received ${item.unit ?? 'units'}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'This action will update your project stock and transactions.',
              style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Confirm Receipt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(materialRequestRepositoryProvider);

      await repo.receiveRequest(
        widget.materialRequest.id,
        _receivedQuantities,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materials received and stock updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record arrival: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Material Arrival'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use this screen to record the quantity of materials that have physically arrived on site. Stock will be updated upon confirmation.',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            Text(
              'Arrival Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            ...widget.materialRequest.items.map((item) => _buildReceptionCard(item)),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitReception,
                icon: const Icon(Icons.inventory),
                label: const Text('CONFIRM PHYSICAL ARRIVAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceptionCard(MaterialRequestItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.materialName ?? 'Material #${item.materialId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordered Qty',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity} ${item.unit ?? 'units'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _quantityControllers[item.id],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Received Qty',
                      suffixText: item.unit ?? 'units',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _receivedQuantities[item.id] = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
