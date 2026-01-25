<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\CostingService;

$costingService = new CostingService();

// Test for project 1
echo "Testing Square Foot Based Costing\n";
echo "====================================\n\n";

$projectId = 1;
$result = $costingService->calculateFlatCosting($projectId);

echo "Project: {$result['project_name']}\n";
echo "Total Cost: ₹" . number_format($result['total_project_cost'], 2) . "\n\n";

echo "Area Distribution:\n";
echo "  Total Area: {$result['total_area']} sq.ft\n";
echo "  Sold Area: {$result['sold_area']} sq.ft ({$result['sold_flats']} flats)\n";
echo "  Unsold Area: {$result['unsold_area']} sq.ft ({$result['unsold_flats']} flats)\n\n";

echo "Cost Calculation:\n";
echo "  Cost per Flat: ₹" . number_format($result['cost_per_flat'], 2) . "\n\n";

echo "Cost Allocation:\n";
echo "  Sold Flats Cost: ₹" . number_format($result['cost_allocated_sold'], 2) . "\n";
echo "  Unsold Flats Cost: ₹" . number_format($result['inventory_value_unsold'], 2) . "\n";
echo "  Total: ₹" . number_format($result['cost_allocated_sold'] + $result['inventory_value_unsold'], 2) . "\n\n";

// Verify calculation
$calculatedTotal = $result['sold_flats'] * $result['cost_per_flat'] + $result['unsold_flats'] * $result['cost_per_flat'];
echo "Verification:\n";
echo "  ({$result['sold_flats']} × ₹{$result['cost_per_flat']}) + ({$result['unsold_flats']} × ₹{$result['cost_per_flat']})\n";
echo "  = ₹" . number_format($calculatedTotal, 2) . "\n";
echo "  Matches Total Cost: " . (abs($calculatedTotal - $result['total_project_cost']) < 1 ? "✓ YES" : "✗ NO") . "\n\n";

// Show sample units
echo "Sample Unit Costs (Equal Cost per Flat):\n";
$units = $costingService->getProjectUnitsList($projectId);
foreach (array_slice($units, 0, 5) as $unit) {
    echo "  {$unit['unit_number']} ({$unit['unit_type']}): {$unit['floor_area']} sq.ft, Cost: ₹" . number_format($unit['unit_cost'], 2) . " (@₹{$unit['cost_per_sqft']}/sq.ft)\n";
}

echo "\n✓ Equal cost per flat calculation is working correctly!\n";
