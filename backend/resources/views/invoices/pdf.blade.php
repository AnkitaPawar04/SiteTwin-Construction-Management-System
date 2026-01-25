<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Invoice {{ $invoice->id }}</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #007bff;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .company-info h1 {
            margin: 0;
            color: #007bff;
            font-size: 28px;
        }
        .invoice-title {
            text-align: right;
        }
        .invoice-title h2 {
            margin: 0;
            color: #007bff;
            font-size: 24px;
        }
        .invoice-title p {
            margin: 5px 0;
            font-size: 12px;
            color: #666;
        }
        .invoice-details {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            font-size: 12px;
        }
        .details-block {
            flex: 1;
        }
        .details-block h4 {
            margin: 0 0 10px 0;
            font-size: 13px;
            font-weight: bold;
            color: #007bff;
        }
        .details-block p {
            margin: 3px 0;
            line-height: 1.4;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        table thead {
            background-color: #007bff;
            color: white;
        }
        table th {
            padding: 12px;
            text-align: left;
            font-weight: bold;
            border: 1px solid #ddd;
            font-size: 12px;
        }
        table td {
            padding: 10px 12px;
            border: 1px solid #ddd;
            font-size: 11px;
        }
        table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .summary {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
        }
        .summary-table {
            width: 300px;
        }
        .summary-table td {
            padding: 8px 12px;
            border: none;
            font-size: 12px;
        }
        .summary-table .label {
            font-weight: bold;
            text-align: right;
            width: 50%;
        }
        .summary-table .value {
            text-align: right;
            width: 50%;
        }
        .summary-table .total-row {
            background-color: #007bff;
            color: white;
            font-weight: bold;
            font-size: 13px;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            font-size: 11px;
            color: #666;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: bold;
        }
        .status-paid {
            background-color: #28a745;
            color: white;
        }
        .status-pending {
            background-color: #ffc107;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="company-info">
                <h1>Construction Management</h1>
                <p style="margin: 5px 0; font-size: 13px; color: #666;">Field Management System</p>
            </div>
            <div class="invoice-title">
                <h2>INVOICE</h2>
                <p><strong>Invoice #:</strong> {{ str_pad($invoice->id, 6, '0', STR_PAD_LEFT) }}</p>
                <p><strong>Date:</strong> {{ $invoice->created_at ? $invoice->created_at->format('d/m/Y') : 'N/A' }}</p>
                <p><strong>Status:</strong> 
                    <span class="status-badge {{ $invoice->status === 'paid' ? 'status-paid' : 'status-pending' }}">
                        {{ strtoupper($invoice->status) }}
                    </span>
                </p>
            </div>
        </div>

        <!-- Invoice Details -->
        <div class="invoice-details">
            <div class="details-block">
                <h4>BILL TO:</h4>
                <p><strong>{{ $invoice->project->name ?? 'N/A' }}</strong></p>
                <p>Location: {{ $invoice->project->location ?? 'N/A' }}</p>
                <p>Project ID: {{ $invoice->project->id ?? 'N/A' }}</p>
            </div>
            <div class="details-block">
                @if($invoice->purchase_order_id)
                    <h4>PURCHASE ORDER:</h4>
                    <p><strong>PO Number:</strong> {{ $invoice->purchaseOrder->po_number ?? 'N/A' }}</p>
                    <p><strong>PO Date:</strong> {{ $invoice->purchaseOrder->created_at ? $invoice->purchaseOrder->created_at->format('d/m/Y') : 'N/A' }}</p>
                    <p><strong>Vendor:</strong> {{ $invoice->purchaseOrder->vendor->name ?? 'N/A' }}</p>
                @else
                    <h4>PROJECT DETAILS:</h4>
                    <p><strong>Project:</strong> {{ $invoice->project->name ?? 'N/A' }}</p>
                    <p><strong>Start Date:</strong> {{ $invoice->project->start_date ? \Carbon\Carbon::parse($invoice->project->start_date)->format('d/m/Y') : 'N/A' }}</p>
                    <p><strong>End Date:</strong> {{ $invoice->project->end_date ? \Carbon\Carbon::parse($invoice->project->end_date)->format('d/m/Y') : 'N/A' }}</p>
                @endif
            </div>
        </div>

        <!-- Items Table -->
        <table>
            <thead>
                <tr>
                    <th style="width: 30%;">Description</th>
                    <th style="width: 10%; text-align: center;">Unit</th>
                    <th style="width: 12%; text-align: right;">Quantity</th>
                    <th style="width: 12%; text-align: right;">Rate (Rs.)</th>
                    <th style="width: 12%; text-align: right;">Amount (Rs.)</th>
                    <th style="width: 12%; text-align: right;">GST %</th>
                    <th style="width: 12%; text-align: right;">Total (Rs.)</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($invoice->items as $item)
                <tr>
                    <td>
                        @if($item->material)
                            {{ $item->material->name }}
                            @if($item->material->code)
                                <br><small style="color: #666;">({{ $item->material->code }})</small>
                            @endif
                        @else
                            {{ $item->description ?? 'N/A' }}
                        @endif
                    </td>
                    <td class="text-center">{{ $item->unit ?? '-' }}</td>
                    <td class="text-right">{{ number_format($item->quantity ?? 1, 2) }}</td>
                    <td class="text-right">{{ number_format($item->rate ?? 0, 2) }}</td>
                    <td class="text-right">{{ number_format($item->amount ?? 0, 2) }}</td>
                    <td class="text-right">{{ $item->gst_percentage ?? 0 }}%</td>
                    <td class="text-right">{{ number_format(($item->total_amount ?? ($item->amount + $item->gst_amount ?? 0)), 2) }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="text-center">No items found</td>
                </tr>
                @endforelse
            </tbody>
        </table>

        <!-- Summary -->
        <div class="summary">
            <table class="summary-table">
                <tr>
                    <td class="label">Subtotal:</td>
                    <td class="value">Rs. {{ number_format($invoice->total_amount ?? 0, 2) }}</td>
                </tr>
                <tr>
                    <td class="label">GST:</td>
                    <td class="value">Rs. {{ number_format($invoice->gst_amount ?? 0, 2) }}</td>
                </tr>
                <tr class="total-row">
                    <td class="label" style="color: white;">TOTAL:</td>
                    <td class="value" style="color: white;">Rs. {{ number_format($invoice->total_amount ?? 0, 2) }}</td>
                </tr>
            </table>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>Thank you for your business!</p>
            <p style="margin-top: 10px; font-size: 10px;">This is a computer-generated invoice. No signature required.</p>
            <p style="margin-top: 10px; border-top: 1px solid #ddd; padding-top: 10px;">Generated on {{ now()->format('d/m/Y H:i') }}</p>
        </div>
    </div>
</body>
</html>
