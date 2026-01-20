<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreStockTransactionRequest;
use App\Services\StockService;
use Illuminate\Http\Request;

class StockController extends Controller
{
    private $stockService;

    public function __construct(StockService $stockService)
    {
        $this->stockService = $stockService;
    }

    public function index(Request $request, $projectId)
    {
        $stock = $this->stockService->getStockByProject($projectId);

        return response()->json([
            'success' => true,
            'data' => $stock
        ]);
    }

    public function transactions(Request $request, $projectId)
    {
        $transactions = $this->stockService->getStockTransactions(
            $projectId,
            $request->query('material_id')
        );

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
    }

    public function addStock(StoreStockTransactionRequest $request)
    {
        try {
            $stock = $this->stockService->addStock(
                $request->project_id,
                $request->material_id,
                $request->quantity,
                $request->reference_id
            );

            return response()->json([
                'success' => true,
                'message' => 'Stock added successfully',
                'data' => $stock
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function removeStock(StoreStockTransactionRequest $request)
    {
        try {
            $stock = $this->stockService->removeStock(
                $request->project_id,
                $request->material_id,
                $request->quantity,
                $request->reference_id
            );

            return response()->json([
                'success' => true,
                'message' => 'Stock removed successfully',
                'data' => $stock
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }
}
