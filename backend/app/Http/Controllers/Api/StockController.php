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

    public function allStock(Request $request)
    {
        $stock = $this->stockService->getAllStock();

        return response()->json([
            'success' => true,
            'data' => $stock
        ]);
    }

    public function allTransactions(Request $request)
    {
        $transactions = $this->stockService->getAllTransactions();

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
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

    /**
     * PHASE 3: Get stock report for a project with GST/Non-GST segregation
     */
    public function getProjectStock(Request $request, $projectId)
    {
        try {
            $report = $this->stockService->getStockReport($projectId);

            return response()->json([
                'success' => true,
                'data' => $report
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch stock report: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * PHASE 3: Get stock movements (transaction history) for a material in a project
     */
    public function getStockMovements(Request $request)
    {
        $validated = $request->validate([
            'material_id' => 'required|exists:materials,id',
            'project_id' => 'required|exists:projects,id',
            'limit' => 'nullable|integer|min:1|max:1000',
        ]);

        try {
            $movements = $this->stockService->getStockMovements(
                $validated['material_id'],
                $validated['project_id'],
                $validated['limit'] ?? null
            );

            return response()->json([
                'success' => true,
                'data' => $movements
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch stock movements: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * PHASE 3: Get current stock summary across all projects
     */
    public function getStockSummary(Request $request)
    {
        try {
            $materials = \App\Models\Material::with('stockTransactions')->get();
            $projects = \App\Models\Project::all();

            $summary = [];

            foreach ($materials as $material) {
                $totalStock = 0;
                $projectStocks = [];

                foreach ($projects as $project) {
                    $stock = $material->getCurrentStock($project->id);
                    if ($stock > 0) {
                        $totalStock += $stock;
                        $projectStocks[] = [
                            'project_id' => $project->id,
                            'project_name' => $project->name,
                            'stock' => $stock
                        ];
                    }
                }

                if ($totalStock > 0) {
                    $summary[] = [
                        'material_id' => $material->id,
                        'material_name' => $material->name,
                        'unit' => $material->unit,
                        'gst_type' => $material->gst_type,
                        'total_stock' => $totalStock,
                        'project_wise_stock' => $projectStocks
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'data' => $summary
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch stock summary: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * PHASE 3: Create stock OUT transaction for task/site consumption
     */
    public function createStockOut(Request $request)
    {
        $validated = $request->validate([
            'material_id' => 'required|exists:materials,id',
            'project_id' => 'required|exists:projects,id',
            'task_id' => 'nullable|exists:tasks,id',
            'quantity' => 'required|numeric|min:0.01',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $stockService = new StockService();
            
            // If task_id is provided, use task-based stock OUT
            if (isset($validated['task_id'])) {
                $transaction = $stockService->createStockOutFromTask(
                    $validated['material_id'],
                    $validated['project_id'],
                    $validated['task_id'],
                    $validated['quantity'],
                    auth()->id()
                );
            } else {
                // Manual adjustment
                $transaction = $stockService->createStockTransaction(
                    materialId: $validated['material_id'],
                    projectId: $validated['project_id'],
                    transactionType: \App\Models\StockTransaction::TYPE_OUT,
                    quantity: $validated['quantity'],
                    referenceType: \App\Models\StockTransaction::REFERENCE_ADJUSTMENT,
                    referenceId: 0,
                    invoiceId: null,
                    performedBy: auth()->id(),
                    notes: $validated['notes'] ?? 'Manual stock OUT'
                );
            }

            return response()->json([
                'success' => true,
                'message' => 'Stock OUT transaction created successfully',
                'data' => $transaction
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create stock OUT: ' . $e->getMessage()
            ], 422);
        }
    }
}
