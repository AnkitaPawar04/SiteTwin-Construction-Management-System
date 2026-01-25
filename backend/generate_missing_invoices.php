<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\PurchaseOrder;
use App\Models\Invoice;
use App\Models\InvoiceItem;

// Find all delivered or closed POs without invoices
$posWithoutInvoices = PurchaseOrder::with('items.material')
    ->whereIn('status', [PurchaseOrder::STATUS_DELIVERED, PurchaseOrder::STATUS_CLOSED])
    ->whereDoesntHave('invoice')
    ->get();

echo "Found " . $posWithoutInvoices->count() . " POs without invoices\n\n";

foreach ($posWithoutInvoices as $po) {
    echo "Generating invoice for PO #{$po->id} ({$po->po_number})...\n";
    
    try {
        // Create invoice
        $invoice = Invoice::create([
            'project_id' => $po->project_id,
            'purchase_order_id' => $po->id,
            'invoice_number' => $po->invoice_number ?? 'INV-' . $po->po_number,
            'total_amount' => $po->grand_total,
            'gst_amount' => $po->gst_amount,
            'status' => Invoice::STATUS_GENERATED,
        ]);

        // Create invoice items from PO items
        foreach ($po->items as $item) {
            InvoiceItem::create([
                'invoice_id' => $invoice->id,
                'material_id' => $item->material_id,
                'quantity' => $item->quantity,
                'unit' => $item->unit,
                'rate' => $item->rate,
                'amount' => $item->amount,
                'gst_percentage' => $item->gst_percentage,
                'gst_amount' => $item->gst_amount,
                'total_amount' => $item->total_amount,
            ]);
        }

        echo "  ✓ Invoice #{$invoice->id} created successfully\n";
        echo "  - Invoice Number: {$invoice->invoice_number}\n";
        echo "  - Total Amount: ₹{$invoice->total_amount}\n";
        echo "  - Items: " . $po->items->count() . "\n\n";
        
    } catch (\Exception $e) {
        echo "  ✗ Error: " . $e->getMessage() . "\n\n";
    }
}

echo "Done!\n";
