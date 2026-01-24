<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Material;
use Illuminate\Support\Facades\DB;

class InvoiceService
{
    public function generateInvoice($projectId, array $items, $taskId = null, $dprId = null)
    {
        return DB::transaction(function () use ($projectId, $items, $taskId, $dprId) {
            $totalAmount = 0;
            $totalGst = 0;

            // Generate invoice number
            $invoiceNumber = 'INV-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

            $invoice = Invoice::create([
                'project_id' => $projectId,
                'task_id' => $taskId,
                'dpr_id' => $dprId,
                'invoice_number' => $invoiceNumber,
                'total_amount' => 0,
                'gst_amount' => 0,
                'status' => Invoice::STATUS_GENERATED,
            ]);

            foreach ($items as $item) {
                $amount = $item['amount'];
                $gstPercentage = $item['gst_percentage'] ?? 0;
                $gstAmount = ($amount * $gstPercentage) / 100;

                InvoiceItem::create([
                    'invoice_id' => $invoice->id,
                    'task_id' => $item['task_id'] ?? null,
                    'description' => $item['description'],
                    'amount' => $amount,
                    'gst_percentage' => $gstPercentage,
                ]);

                $totalAmount += $amount;
                $totalGst += $gstAmount;
            }

            // Update invoice totals
            $invoice->update([
                'total_amount' => $totalAmount + $totalGst,
                'gst_amount' => $totalGst,
            ]);

            return $invoice->load('items');
        });
    }

    public function generateInvoiceFromDpr($dpr)
    {
        // Get all tasks linked to this DPR
        $tasks = $dpr->tasks;
        
        // If no tasks linked, return null
        if ($tasks->isEmpty()) {
            return null;
        }

        $items = [];
        
        // Create an invoice item for each task
        foreach ($tasks as $task) {
            $amount = $task->billing_amount ?? 0;
            $gstPercentage = $task->gst_percentage ?? 18.00;
            
            if ($amount > 0) {
                $items[] = [
                    'description' => "Task: " . $task->title . " - Work completed as per DPR dated " . ($dpr->report_date?->format('d M Y') ?? date('d M Y')),
                    'amount' => $amount,
                    'gst_percentage' => $gstPercentage,
                    'task_id' => $task->id,
                ];
            }
        }

        // Don't generate invoice if no valid items
        if (empty($items)) {
            return null;
        }

        // Use the first task's ID for backward compatibility, or null if no items
        $firstTaskId = $items[0]['task_id'] ?? null;

        return $this->generateInvoice($dpr->project_id, $items, $firstTaskId, $dpr->id);
    }

    public function generateInvoiceFromTask($task)
    {
        if (!$task->billing_amount || $task->billing_amount <= 0) {
            return null;
        }

        $items = [
            [
                'description' => "Task completed: " . $task->title,
                'amount' => $task->billing_amount,
                'gst_percentage' => $task->gst_percentage ?? 18.00,
                'task_id' => $task->id,
            ]
        ];

        return $this->generateInvoice($task->project_id, $items, $task->id);
    }

    public function markAsPaid($invoiceId)
    {
        $invoice = Invoice::findOrFail($invoiceId);
        $invoice->update(['status' => Invoice::STATUS_PAID]);
        return $invoice;
    }

    public function getInvoicesByProject($projectId)
    {
        return Invoice::where('project_id', $projectId)
            ->with('items')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getAllInvoices()
    {
        return Invoice::with(['items', 'project'])
            ->orderBy('created_at', 'desc')
            ->get();
    }
}
