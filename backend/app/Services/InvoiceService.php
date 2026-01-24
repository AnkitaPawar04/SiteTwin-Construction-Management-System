<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Material;
use Illuminate\Support\Facades\DB;

/**
 * DEPRECATED: Task/DPR-based invoice generation is disabled.
 * The system now uses Purchase Order-driven procurement and cost management.
 * Invoices will be managed through vendor invoices linked to Purchase Orders.
 */
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

    /**
     * DEPRECATED: DPR-based invoice generation is disabled.
     * System now uses PO-based procurement.
     */
    public function generateInvoiceFromDpr($dpr)
    {
        // Disabled: Task/DPR-based billing removed
        return null;
    }

    /**
     * DEPRECATED: Task-based invoice generation is disabled.
     * System now uses PO-based procurement.
     */
    public function generateInvoiceFromTask($task)
    {
        // Disabled: Task-based billing removed
        return null;
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
