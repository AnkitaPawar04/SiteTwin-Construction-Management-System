<?php

namespace App\Services;

use App\Models\Material;
use App\Models\StockTransaction;
use App\Models\PurchaseOrder;
use Illuminate\Support\Facades\DB;
use Exception;

class StockService
{
    /**
     * Create stock IN transaction from Purchase Order.
     * 
     * @param PurchaseOrder $purchaseOrder
     * @param string $invoiceId
     * @param int $performedBy User ID
     * @return array Array of created stock transactions
     * @throws Exception
     */
    public function createStockInFromPurchaseOrder(
        PurchaseOrder $purchaseOrder,
        string $invoiceId,
        int $performedBy
    ): array {
        // Validate PO is approved
        if ($purchaseOrder->status !== PurchaseOrder::STATUS_APPROVED) {
            throw new Exception('Purchase Order must be approved before creating stock IN transactions.');
        }

        $transactions = [];

        DB::beginTransaction();
        try {
            foreach ($purchaseOrder->items as $item) {
                $transaction = $this->createStockTransaction(
                    materialId: $item->material_id,
                    projectId: $purchaseOrder->project_id,
                    transactionType: StockTransaction::TYPE_IN,
                    quantity: $item->quantity,
                    referenceType: StockTransaction::REFERENCE_PURCHASE_ORDER,
                    referenceId: $purchaseOrder->id,
                    invoiceId: $invoiceId,
                    performedBy: $performedBy,
                    notes: "Stock IN from PO #{$purchaseOrder->po_number}"
                );

                $transactions[] = $transaction;
            }

            DB::commit();
            return $transactions;
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Create stock OUT transaction from Task consumption.
     * 
     * @param int $materialId
     * @param int $projectId
     * @param int $taskId
     * @param float $quantity
     * @param int $performedBy
     * @return StockTransaction
     * @throws Exception
     */
    public function createStockOutFromTask(
        int $materialId,
        int $projectId,
        int $taskId,
        float $quantity,
        int $performedBy
    ): StockTransaction {
        // Check if sufficient stock available
        $material = Material::findOrFail($materialId);
        
        if (!$material->hasSufficientStock($projectId, $quantity)) {
            throw new Exception(
                "Insufficient stock for material '{$material->name}'. " .
                "Available: {$material->getCurrentStock($projectId)}, Required: {$quantity}"
            );
        }

        return $this->createStockTransaction(
            materialId: $materialId,
            projectId: $projectId,
            transactionType: StockTransaction::TYPE_OUT,
            quantity: $quantity,
            referenceType: StockTransaction::REFERENCE_TASK,
            referenceId: $taskId,
            invoiceId: null,
            performedBy: $performedBy,
            notes: "Stock OUT for Task #{$taskId}"
        );
    }

    /**
     * Create a stock transaction and update balance.
     * 
     * @param int $materialId
     * @param int $projectId
     * @param string $transactionType
     * @param float $quantity
     * @param string $referenceType
     * @param int $referenceId
     * @param string|null $invoiceId
     * @param int $performedBy
     * @param string|null $notes
     * @return StockTransaction
     * @throws Exception
     */
    public function createStockTransaction(
        int $materialId,
        int $projectId,
        string $transactionType,
        float $quantity,
        string $referenceType,
        int $referenceId,
        ?string $invoiceId,
        int $performedBy,
        ?string $notes = null
    ): StockTransaction {
        DB::beginTransaction();
        try {
            // Get current balance
            $material = Material::findOrFail($materialId);
            $currentBalance = $material->getCurrentStock($projectId);

            // Calculate new balance
            if ($transactionType === StockTransaction::TYPE_IN) {
                $newBalance = $currentBalance + $quantity;
            } else {
                // TYPE_OUT
                $newBalance = $currentBalance - $quantity;
                
                // Prevent negative stock
                if ($newBalance < 0) {
                    throw new Exception(
                        "Cannot create stock OUT transaction. " .
                        "Insufficient stock for material '{$material->name}'. " .
                        "Current balance: {$currentBalance}, Requested: {$quantity}"
                    );
                }
            }

            // Create transaction
            $transaction = StockTransaction::create([
                'material_id' => $materialId,
                'project_id' => $projectId,
                'transaction_type' => $transactionType,
                'quantity' => $quantity,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'invoice_id' => $invoiceId,
                'performed_by' => $performedBy,
                'transaction_date' => now(),
                'notes' => $notes,
                'balance_after_transaction' => $newBalance,
            ]);

            DB::commit();
            return $transaction;
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Get stock report for a project with GST/Non-GST segregation.
     * 
     * @param int $projectId
     * @return array
     */
    public function getStockReport(int $projectId): array
    {
        $materials = Material::with(['stockTransactions' => function ($query) use ($projectId) {
            $query->where('project_id', $projectId);
        }])->get();

        $gstStock = [];
        $nonGstStock = [];

        foreach ($materials as $material) {
            $currentStock = $material->getCurrentStock($projectId);
            
            if ($currentStock > 0) {
                $stockData = [
                    'material_id' => $material->id,
                    'material_name' => $material->name,
                    'unit' => $material->unit,
                    'current_stock' => $currentStock,
                    'gst_percentage' => $material->gst_percentage,
                ];

                if ($material->isGstApplicable()) {
                    $gstStock[] = $stockData;
                } else {
                    $nonGstStock[] = $stockData;
                }
            }
        }

        return [
            'project_id' => $projectId,
            'gst_materials' => $gstStock,
            'non_gst_materials' => $nonGstStock,
            'total_gst_items' => count($gstStock),
            'total_non_gst_items' => count($nonGstStock),
        ];
    }

    /**
     * Get stock movement history for a material in a project.
     * 
     * @param int $materialId
     * @param int $projectId
     * @param int|null $limit
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getStockMovements(int $materialId, int $projectId, ?int $limit = null)
    {
        $query = StockTransaction::with(['material', 'performer'])
            ->where('material_id', $materialId)
            ->where('project_id', $projectId)
            ->orderBy('transaction_date', 'desc')
            ->orderBy('id', 'desc');

        if ($limit) {
            $query->limit($limit);
        }

        return $query->get();
    }
}

