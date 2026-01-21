import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock invoice data
    final mockInvoices = [
      {
        'id': 'INV-2026-001',
        'date': '2026-01-15',
        'project': 'Skyline Apartments',
        'amount': 1250000,
        'gst': 225000,
        'total': 1475000,
        'status': 'Paid',
      },
      {
        'id': 'INV-2026-002',
        'date': '2026-01-10',
        'project': 'Green Valley Complex',
        'amount': 850000,
        'gst': 153000,
        'total': 1003000,
        'status': 'Pending',
      },
      {
        'id': 'INV-2025-198',
        'date': '2025-12-28',
        'project': 'Metro Plaza',
        'amount': 2100000,
        'gst': 378000,
        'total': 2478000,
        'status': 'Paid',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature - Coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue (FY 2025-26)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${NumberFormat('#,##,###').format(4956000)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'GST Collected: ₹${NumberFormat('#,##,###').format(756000)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Invoice List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: mockInvoices.length,
              itemBuilder: (context, index) {
                final invoice = mockInvoices[index];
                final isPaid = invoice['status'] == 'Paid';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isPaid
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.warningColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.receipt_long,
                        color: isPaid ? AppTheme.successColor : AppTheme.warningColor,
                      ),
                    ),
                    title: Text(
                      invoice['id'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${invoice['project']}\n${DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['date'] as String))}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(invoice['total'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          label: Text(
                            invoice['status'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor:
                              isPaid ? AppTheme.successColor : AppTheme.warningColor,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildRow('Base Amount:',
                                '₹${NumberFormat('#,##,###').format(invoice['amount'])}'),
                            const SizedBox(height: 8),
                            _buildRow('GST (18%):',
                                '₹${NumberFormat('#,##,###').format(invoice['gst'])}'),
                            const Divider(),
                            _buildRow(
                              'Total Amount:',
                              '₹${NumberFormat('#,##,###').format(invoice['total'])}',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('View PDF - Coming soon'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('View PDF'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Download - Coming soon'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
