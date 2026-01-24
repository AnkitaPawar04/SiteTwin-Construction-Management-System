<?php

require __DIR__.'/vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use App\Models\DailyProgressReport;
use App\Models\Task;
use App\Services\InvoiceService;

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== Testing Multiple Tasks in DPR ===\n\n";

try {
    DB::beginTransaction();
    
    // Find some existing tasks
    $tasks = Task::where('status', 'in_progress')
        ->whereNotNull('billing_amount')
        ->take(2)
        ->get();
    
    if ($tasks->count() < 2) {
        echo "❌ Need at least 2 in-progress tasks with billing amounts\n";
        DB::rollBack();
        exit(1);
    }
    
    echo "Found " . $tasks->count() . " tasks:\n";
    foreach ($tasks as $task) {
        echo "  - {$task->title}: ₹{$task->billing_amount} + {$task->gst_percentage}% GST\n";
    }
    echo "\n";
    
    // Get the project from the first task
    $projectId = $tasks->first()->project_id;
    
    // Get a worker user
    $worker = DB::table('users')->where('role', 'worker')->first();
    if (!$worker) {
        echo "❌ No worker user found\n";
        DB::rollBack();
        exit(1);
    }
    
    // Create a DPR with multiple tasks
    $dpr = DailyProgressReport::create([
        'user_id' => $worker->id,
        'project_id' => $projectId,
        'work_description' => 'Testing multiple tasks: ' . $tasks->pluck('title')->join(', '),
        'report_date' => now()->toDateString(),
        'latitude' => 12.9716,
        'longitude' => 77.5946,
        'status' => DailyProgressReport::STATUS_SUBMITTED,
    ]);
    
    // Attach multiple tasks to the DPR
    $dpr->tasks()->attach($tasks->pluck('id')->toArray());
    
    echo "✅ Created DPR #{$dpr->id} with " . $tasks->count() . " tasks\n\n";
    
    // Load tasks to verify
    $dpr->load('tasks');
    echo "Linked tasks:\n";
    foreach ($dpr->tasks as $task) {
        echo "  - {$task->title}\n";
    }
    echo "\n";
    
    // Now approve the DPR to generate invoice
    $dpr->update(['status' => DailyProgressReport::STATUS_APPROVED]);
    
    $invoiceService = new InvoiceService();
    $invoice = $invoiceService->generateInvoiceFromDpr($dpr);
    
    if ($invoice) {
        echo "✅ Invoice generated successfully!\n";
        echo "Invoice #: {$invoice->invoice_number}\n";
        echo "Total Amount: ₹" . number_format($invoice->total_amount, 2) . "\n";
        echo "GST Amount: ₹" . number_format($invoice->gst_amount, 2) . "\n";
        echo "Subtotal: ₹" . number_format($invoice->subtotal_amount, 2) . "\n\n";
        
        // Load and show invoice items
        $invoice->load('items');
        echo "Invoice Items ({$invoice->items->count()}):\n";
        foreach ($invoice->items as $item) {
            echo "  - {$item->description}\n";
            echo "    Amount: ₹{$item->amount} + {$item->gst_percentage}% GST = ₹" . 
                 number_format($item->amount + ($item->amount * $item->gst_percentage / 100), 2) . "\n";
        }
        
        // Verify number of items matches number of tasks
        if ($invoice->items->count() === $tasks->count()) {
            echo "\n✅ SUCCESS: Invoice has {$invoice->items->count()} items matching {$tasks->count()} tasks!\n";
        } else {
            echo "\n❌ FAILED: Expected {$tasks->count()} items, got {$invoice->items->count()}\n";
        }
    } else {
        echo "❌ Invoice generation failed\n";
    }
    
    DB::rollBack();
    echo "\n✅ Test completed (rolled back)\n";
    
} catch (Exception $e) {
    DB::rollBack();
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
