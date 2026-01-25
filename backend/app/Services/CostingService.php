<?php

namespace App\Services;

use App\Models\Project;
use App\Models\PurchaseOrder;
use App\Models\Material;
use App\Models\MaterialConsumptionStandard;
use App\Models\ProjectUnit;
use App\Models\StockTransaction;
use Illuminate\Support\Facades\DB;

class CostingService
{
    /**
     * Calculate total project cost from all sources:
     * Material (Purchase Orders) + Labor (Daily Wagers) + Misc (Petty Cash)
     * 
     * @param int $projectId
     * @return array
     */
    public function calculateProjectCost(int $projectId): array
    {
        // Material costs from Purchase Orders
        $purchaseOrders = PurchaseOrder::where('project_id', $projectId)
            ->whereIn('status', [
                PurchaseOrder::STATUS_APPROVED,
                PurchaseOrder::STATUS_DELIVERED,
                PurchaseOrder::STATUS_CLOSED
            ])
            ->get();

        $materialCost = 0;
        $totalGstAmount = 0;

        foreach ($purchaseOrders as $po) {
            $materialCost += $po->total_amount;
            $totalGstAmount += $po->gst_amount;
        }

        $materialCostWithGst = $materialCost + $totalGstAmount;

        // Labor costs from Daily Wager Attendance
        $laborCost = DB::table('daily_wager_attendance')
            ->where('project_id', $projectId)
            ->whereIn('status', ['VERIFIED'])
            ->sum('total_wage');

        // Misc expenses from Petty Cash
        $miscCost = DB::table('petty_cash_transactions')
            ->where('project_id', $projectId)
            ->whereIn('status', ['APPROVED', 'PAID'])
            ->sum('amount');

        $totalProjectCost = $materialCostWithGst + $laborCost + $miscCost;

        return [
            'project_id' => $projectId,
            'material_cost' => round($materialCostWithGst, 2),
            'labor_cost' => round($laborCost, 2),
            'misc_cost' => round($miscCost, 2),
            'grand_total_cost' => round($totalProjectCost, 2),
            'calculated_at' => now()->toDateTimeString(),
        ];
    }

    /**
     * Calculate consumption variance for a material.
     * 
     * @param int $projectId
     * @param int $materialId
     * @return array|null
     */
    public function calculateMaterialVariance(int $projectId, int $materialId): ?array
    {
        // Get consumption standard
        $standard = MaterialConsumptionStandard::where('project_id', $projectId)
            ->where('material_id', $materialId)
            ->first();

        if (!$standard) {
            return null;
        }

        // Get actual consumption (total stock OUT for this material)
        $actualConsumption = StockTransaction::where('project_id', $projectId)
            ->where('material_id', $materialId)
            ->where('transaction_type', StockTransaction::TYPE_OUT)
            ->sum('quantity');

        $standardQuantity = $standard->standard_quantity;
        $variance = $actualConsumption - $standardQuantity;
        $variancePercentage = $standardQuantity > 0 
            ? ($variance / $standardQuantity) * 100 
            : 0;

        $maxAllowed = $standard->getMaxAllowedConsumption();
        $isWithinTolerance = $actualConsumption <= $maxAllowed;

        $material = Material::find($materialId);

        return [
            'material_id' => $materialId,
            'material_name' => $material->name,
            'unit' => $standard->unit,
            'standard_quantity' => $standardQuantity,
            'actual_consumption' => $actualConsumption,
            'variance' => round($variance, 2),
            'variance_percentage' => round($variancePercentage, 2),
            'tolerance_percentage' => $standard->variance_tolerance_percentage,
            'max_allowed' => round($maxAllowed, 2),
            'is_within_tolerance' => $isWithinTolerance,
            'alert_status' => !$isWithinTolerance ? 'EXCEEDED' : 'NORMAL',
        ];
    }

    /**
     * Get variance report for all materials in a project.
     * 
     * @param int $projectId
     * @return array
     */
    public function getProjectVarianceReport(int $projectId): array
    {
        $standards = MaterialConsumptionStandard::where('project_id', $projectId)
            ->with('material')
            ->get();

        $variances = [];
        $exceededCount = 0;

        foreach ($standards as $standard) {
            $variance = $this->calculateMaterialVariance($projectId, $standard->material_id);
            if ($variance) {
                $variances[] = $variance;
                if ($variance['alert_status'] === 'EXCEEDED') {
                    $exceededCount++;
                }
            }
        }

        return [
            'project_id' => $projectId,
            'total_materials_tracked' => count($variances),
            'materials_exceeded_tolerance' => $exceededCount,
            'variances' => $variances,
        ];
    }

    /**
     * Calculate flat costing (equal cost per unit).
     * Cost per Flat = Total Project Cost / Total Number of Flats
     * 
     * As per specification: Simple equal distribution across all flats.
     * No profit calculation, no database updates - display only.
     * 
     * @param int $projectId
     * @return array
     */
    public function calculateFlatCosting(int $projectId): array
    {
        $project = Project::findOrFail($projectId);
        $projectCost = $this->calculateProjectCost($projectId);
        
        $units = ProjectUnit::where('project_id', $projectId)->get();
        $totalFlats = $units->count();

        if ($totalFlats === 0) {
            return [
                'project_id' => $projectId,
                'project_name' => $project->name,
                'total_project_cost' => round($projectCost['grand_total_cost'], 2),
                'material_cost' => $projectCost['material_cost'],
                'labor_cost' => $projectCost['labor_cost'],
                'misc_cost' => $projectCost['misc_cost'],
                'total_flats' => 0,
                'cost_per_flat' => 0,
                'sold_flats' => 0,
                'unsold_flats' => 0,
                'cost_allocated_sold' => 0,
                'inventory_value_unsold' => 0,
                'message' => 'No flats/units defined for this project',
            ];
        }

        // Equal distribution: Cost per Flat = Total Cost / Total Flats
        $costPerFlat = $projectCost['grand_total_cost'] / $totalFlats;

        // Count sold and unsold flats
        $soldFlats = $units->where('is_sold', true)->count();
        $unsoldFlats = $totalFlats - $soldFlats;

        // Allocate cost to sold vs unsold
        $costAllocatedSold = $soldFlats * $costPerFlat;
        $inventoryValueUnsold = $unsoldFlats * $costPerFlat;

        return [
            'project_id' => $projectId,
            'project_name' => $project->name,
            'total_project_cost' => round($projectCost['grand_total_cost'], 2),
            'material_cost' => $projectCost['material_cost'],
            'labor_cost' => $projectCost['labor_cost'],
            'misc_cost' => $projectCost['misc_cost'],
            'total_flats' => $totalFlats,
            'cost_per_flat' => round($costPerFlat, 2),
            'sold_flats' => $soldFlats,
            'unsold_flats' => $unsoldFlats,
            'cost_allocated_sold' => round($costAllocatedSold, 2),
            'inventory_value_unsold' => round($inventoryValueUnsold, 2),
        ];
    }

    /**
     * Get list of project units (flats) with sold/unsold status
     * 
     * @param int $projectId
     * @param string|null $status 'sold' or 'unsold', null for all
     * @return array
     */
    public function getProjectUnitsList(int $projectId, ?string $status = null): array
    {
        $query = ProjectUnit::where('project_id', $projectId);

        if ($status === 'sold') {
            $query->where('is_sold', true);
        } elseif ($status === 'unsold') {
            $query->where('is_sold', false);
        }

        $units = $query->orderBy('unit_number')->get();

        return $units->map(function ($unit) {
            return [
                'unit_id' => $unit->id,
                'unit_number' => $unit->unit_number,
                'unit_type' => $unit->unit_type,
                'floor_area' => $unit->floor_area,
                'is_sold' => $unit->is_sold,
                'sold_price' => $unit->sold_price,
                'sold_date' => $unit->sold_date?->format('Y-m-d'),
                'buyer_name' => $unit->buyer_name,
            ];
        })->toArray();
    }

    /**
     * Calculate area-based costing (cost per square foot/meter).
     * 
     * @param int $projectId
     * @return array
     */
    public function calculateAreaBasedCosting(int $projectId): array
    {
        $project = Project::findOrFail($projectId);
        $projectCost = $this->calculateProjectCost($projectId);
        
        $units = ProjectUnit::where('project_id', $projectId)->get();
        $totalArea = $units->sum('floor_area');

        if ($totalArea == 0) {
            return [
                'project_id' => $projectId,
                'total_cost' => $projectCost['grand_total_cost'],
                'total_area' => 0,
                'cost_per_sqft' => 0,
                'message' => 'No floor area defined for units',
            ];
        }

        $costPerSqft = $projectCost['grand_total_cost'] / $totalArea;

        // Update allocated cost for each unit based on area
        foreach ($units as $unit) {
            $allocatedCost = $unit->floor_area * $costPerSqft;
            $unit->update(['allocated_cost' => $allocatedCost]);
        }

        $soldUnits = $units->where('is_sold', true);
        $unsoldUnits = $units->where('is_sold', false);

        $soldArea = $soldUnits->sum('floor_area');
        $unsoldArea = $unsoldUnits->sum('floor_area');
        $soldRevenue = $soldUnits->sum('sold_price');
        $soldCost = $soldArea * $costPerSqft;
        $unsoldCost = $unsoldArea * $costPerSqft;

        return [
            'project_id' => $projectId,
            'project_name' => $project->name,
            'total_project_cost' => round($projectCost['grand_total_cost'], 2),
            'total_area' => round($totalArea, 2),
            'area_unit' => $units->first()->floor_area_unit ?? 'sqft',
            'cost_per_unit_area' => round($costPerSqft, 2),
            'sold_area' => round($soldArea, 2),
            'unsold_area' => round($unsoldArea, 2),
            'sold_units_revenue' => round($soldRevenue, 2),
            'sold_units_cost' => round($soldCost, 2),
            'unsold_units_inventory_value' => round($unsoldCost, 2),
            'total_profit_loss' => round($soldRevenue - $soldCost, 2),
        ];
    }

    /**
     * Get materials that exceeded variance tolerance.
     * 
     * @param int $projectId
     * @return array
     */
    public function getWastageAlerts(int $projectId): array
    {
        $varianceReport = $this->getProjectVarianceReport($projectId);
        
        $alerts = array_filter($varianceReport['variances'], function($variance) {
            return $variance['alert_status'] === 'EXCEEDED';
        });

        return [
            'project_id' => $projectId,
            'alert_count' => count($alerts),
            'alerts' => array_values($alerts),
        ];
    }

    /**
     * Get detailed unit-wise costing breakdown.
     * 
     * @param int $projectId
     * @return array
     */
    public function getUnitWiseCosting(int $projectId): array
    {
        $units = ProjectUnit::where('project_id', $projectId)
            ->orderBy('unit_number')
            ->get();

        $unitDetails = [];

        foreach ($units as $unit) {
            $profitLoss = $unit->getProfitLoss();
            $profitMargin = $unit->getProfitMargin();

            $unitDetails[] = [
                'unit_number' => $unit->unit_number,
                'unit_type' => $unit->unit_type,
                'floor_area' => $unit->floor_area,
                'area_unit' => $unit->floor_area_unit,
                'allocated_cost' => $unit->allocated_cost,
                'is_sold' => $unit->is_sold,
                'sold_price' => $unit->sold_price,
                'sold_date' => $unit->sold_date,
                'buyer_name' => $unit->buyer_name,
                'profit_loss' => $profitLoss,
                'profit_margin_percentage' => $profitMargin,
            ];
        }

        return [
            'project_id' => $projectId,
            'total_units' => count($unitDetails),
            'units' => $unitDetails,
        ];
    }
}
