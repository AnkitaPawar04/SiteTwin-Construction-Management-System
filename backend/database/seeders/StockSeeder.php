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
        // Note: Stock transactions are now managed through StockService
        // This seeder creates initial stock for testing purposes only
        
        // Project 1 Stock - Based on approved material requests
        $project1Stock = [
            ['material_id' => 1, 'quantity' => 150, 'consumed' => 150],  // Cement (200+100-150)
            ['material_id' => 5, 'quantity' => 2500, 'consumed' => 2500], // Steel 8mm (5000-2500)
            ['material_id' => 11, 'quantity' => 35, 'consumed' => 45],    // Sand (50+30-45)
            ['material_id' => 15, 'quantity' => 6000, 'consumed' => 4000], // Bricks (10000-4000)
        ];

        $transactionCount = 0;
        
        foreach ($project1Stock as $item) {
            $total = $item['quantity'] + $item['consumed'];
            
            // Stock IN transaction (from purchase order)
            StockTransaction::create([
                'project_id' => 1,
                'material_id' => $item['material_id'],
                'quantity' => $total,
                'transaction_type' => 'in',
                'reference_type' => 'purchase_order',
                'reference_id' => 1,
                'invoice_id' => 'PO-2026-001',
                'performed_by' => 5, // Purchase Manager
                'transaction_date' => Carbon::now()->subDays(8),
                'balance_after_transaction' => $total,
                'notes' => 'Initial stock from PO',
                'created_at' => Carbon::now()->subDays(8),
                'updated_at' => Carbon::now()->subDays(8),
            ]);
            $transactionCount++;

            // Stock OUT transaction (consumption)
            if ($item['consumed'] > 0) {
                StockTransaction::create([
                    'project_id' => 1,
                    'material_id' => $item['material_id'],
                    'quantity' => $item['consumed'],
                    'transaction_type' => 'out',
                    'reference_type' => 'task',
                    'reference_id' => 1,
                    'invoice_id' => null,
                    'performed_by' => 2, // Manager
                    'transaction_date' => Carbon::now()->subDays(2),
                    'balance_after_transaction' => $item['quantity'],
                    'notes' => 'Used in construction',
                    'created_at' => Carbon::now()->subDays(2),
                    'updated_at' => Carbon::now()->subDays(2),
                ]);
                $transactionCount++;
            }
        }

        // Project 2 Stock
        $project2Stock = [
            ['material_id' => 1, 'quantity' => 120, 'consumed' => 30],   // Cement (150-30)
            ['material_id' => 7, 'quantity' => 2700, 'consumed' => 300], // Steel 12mm (3000-300)
            ['material_id' => 13, 'quantity' => 38, 'consumed' => 2],    // Aggregate (40-2)
        ];

        foreach ($project2Stock as $item) {
            $total = $item['quantity'] + $item['consumed'];
            
            // Stock IN
            StockTransaction::create([
                'project_id' => 2,
                'material_id' => $item['material_id'],
                'quantity' => $total,
                'transaction_type' => 'in',
                'reference_type' => 'purchase_order',
                'reference_id' => 2,
                'invoice_id' => 'PO-2026-002',
                'performed_by' => 5, // Purchase Manager
                'transaction_date' => Carbon::now()->subDays(6),
                'balance_after_transaction' => $total,
                'notes' => 'Initial stock from PO',
                'created_at' => Carbon::now()->subDays(6),
                'updated_at' => Carbon::now()->subDays(6),
            ]);
            $transactionCount++;

            // Stock OUT
            if ($item['consumed'] > 0) {
                StockTransaction::create([
                    'project_id' => 2,
                    'material_id' => $item['material_id'],
                    'quantity' => $item['consumed'],
                    'transaction_type' => 'out',
                    'reference_type' => 'task',
                    'reference_id' => 2,
                    'invoice_id' => null,
                    'performed_by' => 2, // Manager
                    'transaction_date' => Carbon::now()->subDays(1),
                    'balance_after_transaction' => $item['quantity'],
                    'notes' => 'Used in construction',
                    'created_at' => Carbon::now()->subDays(1),
                    'updated_at' => Carbon::now()->subDays(1),
                ]);
                $transactionCount++;
            }
        }

        $this->command->info("Created {$transactionCount} stock transactions");
    }
}
