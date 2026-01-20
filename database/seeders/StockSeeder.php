<?php

namespace Database\Seeders;

use App\Models\Stock;
use App\Models\StockTransaction;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class StockSeeder extends Seeder
{
    public function run()
    {
        // Project 1 Stock - Based on approved material requests
        $project1Stock = [
            ['material_id' => 1, 'quantity' => 150, 'consumed' => 150],  // Cement (200+100-150)
            ['material_id' => 5, 'quantity' => 2500, 'consumed' => 2500], // Steel 8mm (5000-2500)
            ['material_id' => 11, 'quantity' => 35, 'consumed' => 45],    // Sand (50+30-45)
            ['material_id' => 15, 'quantity' => 6000, 'consumed' => 4000], // Bricks (10000-4000)
        ];

        foreach ($project1Stock as $item) {
            $total = $item['quantity'] + $item['consumed'];
            
            Stock::create([
                'project_id' => 1,
                'material_id' => $item['material_id'],
                'available_quantity' => $item['quantity'],
                'updated_at' => Carbon::now()->subDays(1),
            ]);

            // Stock IN transaction (from material request)
            StockTransaction::create([
                'project_id' => 1,
                'material_id' => $item['material_id'],
                'quantity' => $total,
                'type' => 'in',
                'reference_id' => 1, // Material Request ID
                'created_at' => Carbon::now()->subDays(8),
            ]);

            // Stock OUT transaction (consumption)
            if ($item['consumed'] > 0) {
                StockTransaction::create([
                    'project_id' => 1,
                    'material_id' => $item['material_id'],
                    'quantity' => $item['consumed'],
                    'type' => 'out',
                    'reference_id' => null,
                    'created_at' => Carbon::now()->subDays(2),
                ]);
            }
        }

        // Project 2 Stock
        $project2Stock = [
            ['material_id' => 1, 'quantity' => 120, 'consumed' => 30],   // Cement (150-30)
            ['material_id' => 7, 'quantity' => 2700, 'consumed' => 300], // Steel 12mm (3000-300)
            ['material_id' => 13, 'quantity' => 38, 'consumed' => 2],    // Aggregate (40-2)
        ];

        foreach ($project2Stock as $item) {
            Stock::create([
                'project_id' => 2,
                'material_id' => $item['material_id'],
                'available_quantity' => $item['quantity'],
                'updated_at' => Carbon::now()->subDays(1),
            ]);

            // Stock IN
            StockTransaction::create([
                'project_id' => 2,
                'material_id' => $item['material_id'],
                'quantity' => $item['quantity'] + $item['consumed'],
                'type' => 'in',
                'reference_id' => 3,
                'created_at' => Carbon::now()->subDays(6),
            ]);

            // Stock OUT
            if ($item['consumed'] > 0) {
                StockTransaction::create([
                    'project_id' => 2,
                    'material_id' => $item['material_id'],
                    'quantity' => $item['consumed'],
                    'type' => 'out',
                    'reference_id' => null,
                    'created_at' => Carbon::now()->subDays(1),
                ]);
            }
        }

        $stockCount = Stock::count();
        $transactionCount = StockTransaction::count();
        $this->command->info("Created {$stockCount} stock records and {$transactionCount} transactions");
    }
}
