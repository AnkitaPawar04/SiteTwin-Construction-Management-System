<?php

/**
 * Quick test script to verify flat costing calculation logic
 * Run from backend directory: php test_flat_costing.php
 */

// Simulate the calculation logic
function testFlatCosting() {
    echo "=== Testing Flat Costing Calculation ===\n\n";
    
    // Test Case 1: Standard scenario
    echo "Test Case 1: Standard Project\n";
    echo "-------------------------------\n";
    
    $materialCost = 60000000; // ₹6 Cr
    $laborCost = 30000000;    // ₹3 Cr
    $miscCost = 10000000;     // ₹1 Cr
    
    $totalProjectCost = $materialCost + $laborCost + $miscCost;
    $totalFlats = 100;
    $soldFlats = 60;
    $unsoldFlats = 40;
    
    $costPerFlat = $totalProjectCost / $totalFlats;
    $costAllocatedSold = $soldFlats * $costPerFlat;
    $inventoryValueUnsold = $unsoldFlats * $costPerFlat;
    
    echo "Material Cost: ₹" . number_format($materialCost) . "\n";
    echo "Labor Cost: ₹" . number_format($laborCost) . "\n";
    echo "Misc Cost: ₹" . number_format($miscCost) . "\n";
    echo "Total Project Cost: ₹" . number_format($totalProjectCost) . "\n\n";
    
    echo "Total Flats: $totalFlats\n";
    echo "Cost per Flat: ₹" . number_format($costPerFlat) . "\n\n";
    
    echo "Sold Flats: $soldFlats\n";
    echo "Cost Allocated (Sold): ₹" . number_format($costAllocatedSold) . "\n\n";
    
    echo "Unsold Flats: $unsoldFlats\n";
    echo "Inventory Value (Unsold): ₹" . number_format($inventoryValueUnsold) . "\n\n";
    
    // Verify totals match
    $verification = $costAllocatedSold + $inventoryValueUnsold;
    echo "Verification (Sold + Unsold = Total): ₹" . number_format($verification) . "\n";
    echo "Match: " . ($verification == $totalProjectCost ? "✓ YES" : "✗ NO") . "\n\n";
    
    // Test Case 2: All units sold
    echo "\nTest Case 2: All Flats Sold\n";
    echo "-----------------------------\n";
    $totalFlats2 = 50;
    $soldFlats2 = 50;
    $unsoldFlats2 = 0;
    
    $costPerFlat2 = $totalProjectCost / $totalFlats2;
    $costAllocatedSold2 = $soldFlats2 * $costPerFlat2;
    $inventoryValueUnsold2 = $unsoldFlats2 * $costPerFlat2;
    
    echo "Total Flats: $totalFlats2\n";
    echo "Cost per Flat: ₹" . number_format($costPerFlat2) . "\n";
    echo "Sold: $soldFlats2, Cost: ₹" . number_format($costAllocatedSold2) . "\n";
    echo "Unsold: $unsoldFlats2, Value: ₹" . number_format($inventoryValueUnsold2) . "\n\n";
    
    echo "=== All Tests Completed ===\n";
}

testFlatCosting();
