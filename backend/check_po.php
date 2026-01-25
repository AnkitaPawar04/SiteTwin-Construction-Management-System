<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$po = App\Models\PurchaseOrder::with('invoice')->find(4);

if ($po) {
    echo "PO #4 Status: " . $po->status . "\n";
    echo "Delivered at: " . ($po->delivered_at ?? 'NULL') . "\n";
    echo "Has Invoice: " . ($po->invoice ? 'YES (ID: ' . $po->invoice->id . ')' : 'NO') . "\n";
    
    // Check if any invoice exists for this PO
    $invoices = App\Models\Invoice::where('purchase_order_id', 4)->get();
    echo "Invoices in DB: " . $invoices->count() . "\n";
    foreach ($invoices as $inv) {
        echo "  - Invoice ID: " . $inv->id . ", Number: " . $inv->invoice_number . ", Status: " . $inv->status . "\n";
    }
} else {
    echo "PO #4 not found\n";
}
