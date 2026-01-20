<?php

namespace App\Services;

use App\Models\Stock;
use App\Models\StockTransaction;
use Illuminate\Support\Facades\DB;

class StockService
{
    public function addStock($projectId, $materialId, $quantity, $referenceId = null)
    {
        return DB::transaction(function () use ($projectId, $materialId, $quantity, $referenceId) {
            // Find or create stock record
            $stock = Stock::firstOrCreate(
                [
                    'project_id' => $projectId,
                    'material_id' => $materialId,
                ],
                [
                    'available_quantity' => 0,
                ]
            );

            // Update available quantity
            $stock->increment('available_quantity', $quantity);
            $stock->touch('updated_at');

            // Create transaction record
            StockTransaction::create([
                'project_id' => $projectId,
                'material_id' => $materialId,
                'quantity' => $quantity,
                'type' => StockTransaction::TYPE_IN,
                'reference_id' => $referenceId,
            ]);

            return $stock;
        });
    }

    public function removeStock($projectId, $materialId, $quantity, $referenceId = null)
    {
        return DB::transaction(function () use ($projectId, $materialId, $quantity, $referenceId) {
            $stock = Stock::where('project_id', $projectId)
                ->where('material_id', $materialId)
                ->firstOrFail();

            if ($stock->available_quantity < $quantity) {
                throw new \Exception('Insufficient stock available');
            }

            // Update available quantity
            $stock->decrement('available_quantity', $quantity);
            $stock->touch('updated_at');

            // Create transaction record
            StockTransaction::create([
                'project_id' => $projectId,
                'material_id' => $materialId,
                'quantity' => $quantity,
                'type' => StockTransaction::TYPE_OUT,
                'reference_id' => $referenceId,
            ]);

            return $stock;
        });
    }

    public function getStockByProject($projectId)
    {
        return Stock::where('project_id', $projectId)
            ->with('material')
            ->get();
    }

    public function getStockTransactions($projectId, $materialId = null)
    {
        $query = StockTransaction::where('project_id', $projectId)
            ->with('material');

        if ($materialId) {
            $query->where('material_id', $materialId);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }
}
