<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MaterialConsumptionStandard;
use App\Models\ProjectUnit;
use App\Services\CostingService;
use Illuminate\Http\Request;

class CostingController extends Controller
{
    protected $costingService;

    public function __construct(CostingService $costingService)
    {
        $this->costingService = $costingService;
    }

    /**
     * Get project cost summary from Purchase Orders
     */
    public function getProjectCost(Request $request, $projectId)
    {
        try {
            $costSummary = $this->costingService->calculateProjectCost($projectId);

            return response()->json([
                'success' => true,
                'data' => $costSummary
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to calculate project cost: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get consumption variance report for a project
     */
    public function getVarianceReport(Request $request, $projectId)
    {
        try {
            $varianceReport = $this->costingService->getProjectVarianceReport($projectId);

            return response()->json([
                'success' => true,
                'data' => $varianceReport
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate variance report: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get variance for a specific material
     */
    public function getMaterialVariance(Request $request, $projectId, $materialId)
    {
        try {
            $variance = $this->costingService->calculateMaterialVariance($projectId, $materialId);

            if (!$variance) {
                return response()->json([
                    'success' => false,
                    'message' => 'No consumption standard defined for this material'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $variance
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to calculate variance: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get flat costing (equal cost per unit)
     */
    public function getFlatCosting(Request $request, $projectId)
    {
        try {
            $flatCosting = $this->costingService->calculateFlatCosting($projectId);

            return response()->json([
                'success' => true,
                'data' => $flatCosting
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to calculate flat costing: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get list of project units (flats) - sold/unsold
     */
    public function getUnitsList(Request $request, $projectId)
    {
        try {
            $status = $request->query('status'); // 'sold', 'unsold', or null for all
            $units = $this->costingService->getProjectUnitsList($projectId, $status);

            return response()->json([
                'success' => true,
                'data' => $units,
                'count' => count($units)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get units list: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get area-based costing (cost per sqft/sqm)
     */
    public function getAreaBasedCosting(Request $request, $projectId)
    {
        try {
            $areaCosting = $this->costingService->calculateAreaBasedCosting($projectId);

            return response()->json([
                'success' => true,
                'data' => $areaCosting
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to calculate area-based costing: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get wastage alerts (materials exceeding tolerance)
     */
    public function getWastageAlerts(Request $request, $projectId)
    {
        try {
            $alerts = $this->costingService->getWastageAlerts($projectId);

            return response()->json([
                'success' => true,
                'data' => $alerts
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch wastage alerts: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get unit-wise costing details
     */
    public function getUnitWiseCosting(Request $request, $projectId)
    {
        try {
            $unitCosting = $this->costingService->getUnitWiseCosting($projectId);

            return response()->json([
                'success' => true,
                'data' => $unitCosting
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch unit costing: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Create or update consumption standard
     */
    public function storeConsumptionStandard(Request $request)
    {
        $validated = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'material_id' => 'required|exists:materials,id',
            'standard_quantity' => 'required|numeric|min:0.01',
            'unit' => 'required|string|max:50',
            'variance_tolerance_percentage' => 'nullable|numeric|min:0|max:100',
            'description' => 'nullable|string|max:500',
        ]);

        try {
            $standard = MaterialConsumptionStandard::updateOrCreate(
                [
                    'project_id' => $validated['project_id'],
                    'material_id' => $validated['material_id'],
                ],
                [
                    'standard_quantity' => $validated['standard_quantity'],
                    'unit' => $validated['unit'],
                    'variance_tolerance_percentage' => $validated['variance_tolerance_percentage'] ?? 10.00,
                    'description' => $validated['description'] ?? null,
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'Consumption standard saved successfully',
                'data' => $standard
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save consumption standard: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get consumption standards for a project
     */
    public function getConsumptionStandards(Request $request, $projectId)
    {
        try {
            $standards = MaterialConsumptionStandard::where('project_id', $projectId)
                ->with('material')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $standards
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch consumption standards: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Create or update project unit
     */
    public function storeProjectUnit(Request $request)
    {
        $validated = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'unit_number' => 'required|string|max:50',
            'unit_type' => 'required|string|max:50',
            'floor_area' => 'required|numeric|min:0.01',
            'floor_area_unit' => 'nullable|string|in:sqft,sqm',
            'is_sold' => 'nullable|boolean',
            'sold_price' => 'nullable|numeric|min:0',
            'sold_date' => 'nullable|date',
            'buyer_name' => 'nullable|string|max:255',
            'description' => 'nullable|string',
        ]);

        try {
            $unit = ProjectUnit::updateOrCreate(
                [
                    'project_id' => $validated['project_id'],
                    'unit_number' => $validated['unit_number'],
                ],
                $validated
            );

            return response()->json([
                'success' => true,
                'message' => 'Project unit saved successfully',
                'data' => $unit
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save project unit: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get project units
     */
    public function getProjectUnits(Request $request, $projectId)
    {
        try {
            $units = ProjectUnit::where('project_id', $projectId)
                ->orderBy('unit_number')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $units
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch project units: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark unit as sold
     */
    public function markUnitSold(Request $request, $unitId)
    {
        $validated = $request->validate([
            'sold_price' => 'required|numeric|min:0',
            'sold_date' => 'required|date',
            'buyer_name' => 'required|string|max:255',
        ]);

        try {
            $unit = ProjectUnit::findOrFail($unitId);
            
            $unit->update([
                'is_sold' => true,
                'sold_price' => $validated['sold_price'],
                'sold_date' => $validated['sold_date'],
                'buyer_name' => $validated['buyer_name'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Unit marked as sold successfully',
                'data' => $unit
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update unit: ' . $e->getMessage()
            ], 422);
        }
    }
}
