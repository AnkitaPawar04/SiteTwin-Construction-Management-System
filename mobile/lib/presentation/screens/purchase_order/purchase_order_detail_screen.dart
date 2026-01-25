import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/data/models/purchase_order_model.dart';
import 'package:mobile/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Purchase Order Detail Screen
/// Shows PO details and allows status updates (approve, deliver, close)
/// Purchase Manager can approve, Manager can mark delivered
class PurchaseOrderDetailScreen extends ConsumerStatefulWidget {
  final int purchaseOrderId;

  const PurchaseOrderDetailScreen({
    super.key,
    required this.purchaseOrderId,
  });

  @override
  ConsumerState<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState
    extends ConsumerState<PurchaseOrderDetailScreen> {
  bool _isLoading = false;
  PurchaseOrderModel? _purchaseOrder;

  @override
  void initState() {
    super.initState();
    _loadPurchaseOrder();
  }

  Future<void> _loadPurchaseOrder() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      final po = await repository.getPurchaseOrderById(widget.purchaseOrderId);

      setState(() {
        _purchaseOrder = po;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PO: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadInvoice() async {
    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file selected')),
      );
      return;
    }

    // Show dialog to get invoice number
    final invoiceNumber = await showDialog<String>(
      context: context,
      builder: (context) => const _InvoiceUploadDialog(),
    );

    if (invoiceNumber == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      await repository.uploadInvoice(
        id: widget.purchaseOrderId,
        invoicePath: file.path!,
        invoiceNumber: invoiceNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice uploaded successfully! You can now approve the PO.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        _loadPurchaseOrder(); // Reload
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload invoice: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    // Check if trying to approve without invoice
    if (newStatus.toLowerCase() == 'approved' && 
        (_purchaseOrder?.invoiceUrl == null || _purchaseOrder!.invoiceUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload invoice before approving PO'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to $newStatus?'),
        content: Text(
          newStatus.toLowerCase() == 'approved'
              ? 'Approving this PO will automatically add stock to inventory. Continue?'
              : 'Are you sure you want to mark this PO as $newStatus?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      // Send lowercase status to backend
      await repository.updateStatus(widget.purchaseOrderId, newStatus.toLowerCase());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus.toLowerCase() == 'approved'
                  ? 'PO approved! Stock added to inventory.'
                  : 'PO status updated to $newStatus'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadPurchaseOrder(); // Reload
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _viewInvoice(String invoiceUrl) {
    // Construct full URL for the invoice
    final baseUrl = 'http://172.16.23.211:8000'; // TODO: Get from settings
    final fullUrl = '$baseUrl/storage/$invoiceUrl';
    
    // Open in browser or show dialog with options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Invoice file is available'),
            const SizedBox(height: 8),
            Text(
              'Path: $invoiceUrl',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual viewing/downloading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice URL: $fullUrl')),
              );
              Navigator.pop(context);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewSystemInvoice() async {
    if (_purchaseOrder == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(purchaseOrderRepositoryProvider);
      final invoiceData = await repository.getInvoice(_purchaseOrder!.id);
      
      setState(() => _isLoading = false);
      
      if (invoiceData != null && invoiceData['id'] != null) {
        final invoiceId = invoiceData['id'];
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _InvoicePdfViewerScreen(invoiceId: invoiceId),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice not yet generated')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load invoice: $e')),
        );
      }
    }
  }

  Color _getStatusColor() {
    if (_purchaseOrder == null) return Colors.grey;
    
    switch (_purchaseOrder!.status.toUpperCase()) {
      case 'CREATED':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _purchaseOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_purchaseOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Order')),
        body: const Center(child: Text('Failed to load purchase order')),
      );
    }

    final po = _purchaseOrder!;

    return Scaffold(
      appBar: AppBar(
        title: Text(po.poNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPurchaseOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: _getStatusColor().withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status', style: TextStyle(fontSize: 12)),
                            Text(
                              po.status,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
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

              // PO Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Purchase Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('PO Number', po.poNumber),
                      _buildInfoRow('PO Date', _formatDate(po.poDate)),
                      _buildInfoRow('Vendor', po.vendorName ?? 'Vendor #${po.vendorId}'),
                      _buildInfoRow('GST Type', po.gstTypeLabel),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Invoice Card (if uploaded)
              if (po.invoiceUrl != null && po.invoiceUrl!.isNotEmpty)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Invoice Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (po.invoiceNumber != null && po.invoiceNumber!.isNotEmpty)
                          _buildInfoRow('Invoice Number', po.invoiceNumber!),
                        if (po.invoiceType != null && po.invoiceType!.isNotEmpty)
                          _buildInfoRow('Invoice Type', po.invoiceType!.toUpperCase()),
                        _buildInfoRow('Status', 'Uploaded'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _viewInvoice(po.invoiceUrl!),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Invoice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (po.invoiceUrl != null && po.invoiceUrl!.isNotEmpty)
                const SizedBox(height: 16),

              // System Generated Invoice Card (shown after PO is delivered)
              if (po.status.toUpperCase() == 'DELIVERED' || po.status.toUpperCase() == 'CLOSED')
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'System Invoice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Type', 'Auto-Generated'),
                        _buildInfoRow('Status', 'Generated'),
                        const Text(
                          'System invoice includes all PO items with GST breakdown',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _viewSystemInvoice,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('View Invoice PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (po.status.toUpperCase() == 'DELIVERED' || po.status.toUpperCase() == 'CLOSED')
                const SizedBox(height: 16),

              // Items Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      ...po.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Quantity',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        Text(
                                          '${item.quantity} ${item.unit}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rate',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        Text(
                                          '₹${item.unitPrice.toStringAsFixed(2)}/${item.unit ?? 'unit'}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    if (item.gstRate > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'GST',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          Text(
                                            '${item.gstRate}%',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Amount',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '₹${item.totalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (index < po.items.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Divider(),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Total Card
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('₹${_calculateSubtotal(po).toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST'),
                          Text('₹${_calculateGST(po).toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
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
                            '₹${po.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget? _buildActionButton() {
    if (_purchaseOrder == null) return null;

    final status = _purchaseOrder!.status.toUpperCase();
    final hasInvoice = _purchaseOrder!.invoiceUrl != null && _purchaseOrder!.invoiceUrl!.isNotEmpty;

    // Purchase Manager can approve CREATED POs (after uploading invoice)
    if (status == 'CREATED') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Upload Invoice Button
            FloatingActionButton.extended(
              onPressed: _isLoading ? null : _uploadInvoice,
              icon: const Icon(Icons.upload_file),
              label: Text(hasInvoice ? 'Re-upload Invoice' : 'Upload Invoice'),
              backgroundColor: _isLoading ? Colors.grey : Colors.orange,
              heroTag: 'upload',
            ),
            const SizedBox(height: 12),
            // Approve Button
            FloatingActionButton.extended(
              onPressed: _isLoading ? null : () => _updateStatus(AppConstants.poApproved),
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve PO'),
              backgroundColor: _isLoading ? Colors.grey : (hasInvoice ? Colors.blue : Colors.grey),
              heroTag: 'approve',
            ),
          ],
        ),
      );
    }

    // Manager can mark APPROVED POs as delivered
    if (status == 'APPROVED') {
      return FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _updateStatus(AppConstants.poDelivered),
        icon: const Icon(Icons.local_shipping),
        label: const Text('Mark Delivered'),
        backgroundColor: _isLoading ? Colors.grey : Colors.green,
      );
    }

    // Manager can close DELIVERED POs
    if (status == 'DELIVERED') {
      return FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _updateStatus(AppConstants.poClosed),
        icon: const Icon(Icons.done_all),
        label: const Text('Close PO'),
        backgroundColor: _isLoading ? Colors.grey : Colors.grey[700],
      );
    }

    return null;
  }

  IconData _getStatusIcon() {
    if (_purchaseOrder == null) return Icons.description;
    
    switch (_purchaseOrder!.status.toUpperCase()) {
      case 'CREATED':
        return Icons.create;
      case 'APPROVED':
        return Icons.check_circle;
      case 'DELIVERED':
        return Icons.local_shipping;
      case 'CLOSED':
        return Icons.done_all;
      default:
        return Icons.description;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal(PurchaseOrderModel po) {
    return po.items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateGST(PurchaseOrderModel po) {
    return po.items.fold(0.0, (sum, item) => sum + item.gstAmount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}

/// Dialog for entering invoice details
class _InvoiceUploadDialog extends StatefulWidget {
  const _InvoiceUploadDialog();

  @override
  State<_InvoiceUploadDialog> createState() => _InvoiceUploadDialogState();
}

class _InvoiceUploadDialogState extends State<_InvoiceUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invoice Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                hintText: 'e.g., INV-2026-001',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Invoice number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Supports mixed GST & Non-GST items',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _invoiceNumberController.text.trim());
            }
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

/// Screen to view system-generated invoice PDF
class _InvoicePdfViewerScreen extends StatelessWidget {
  final int invoiceId;

  const _InvoicePdfViewerScreen({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Invoice'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String?>(
        future: _loadToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final token = snapshot.data;
          if (token == null || token.isEmpty) {
            return const Center(child: Text('Missing auth token. Please log in again.'));
          }

          final url = '${ApiConstants.baseUrl}/invoices/$invoiceId/view-pdf';

          return SfPdfViewer.network(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/pdf',
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading PDF: ${details.error}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}
