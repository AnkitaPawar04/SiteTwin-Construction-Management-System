<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\MaterialConsumptionStandard;
use App\Models\StockTransaction;
use App\Models\Project;
use App\Models\Material;
use App\Models\User;

class ConsumptionVarianceSeeder extends Seeder
{
    /**
     * Seed data for consumption variance feature.
     * Creates consumption standards and stock transactions to demonstrate variance alerts.
     */
    public function run(): void
    {
        // Get first project and manager
        $project = Project::first();
        $material1 = Material::where('name', 'LIKE', '%Cement%')->first();
        $material2 = Material::where('name', 'LIKE', '%Steel%')->first();
        $material3 = Material::where('name', 'LIKE', '%Sand%')->first();
        $material4 = Material::where('name', 'LIKE', '%Brick%')->first();
        $manager = User::where('role', 'manager')->first();

        if (!$project || !$manager) {
            $this->command->error('Project or Manager not found. Please run ProjectSeeder and UserSeeder first.');
            return;
        }

        // If materials don't exist, create them
        if (!$material1) {
            $material1 = Material::create([
                'name' => 'Portland Cement (50kg)',
                'unit' => 'bags',
                'description' => 'OPC 43 Grade Cement',
            ]);
        }

        if (!$material2) {
            $material2 = Material::create([
                'name' => 'TMT Steel Bars (12mm)',
                'unit' => 'kg',
                'description' => 'TMT Fe500 Grade Steel',
            ]);
        }

        if (!$material3) {
            $material3 = Material::create([
                'name' => 'River Sand',
                'unit' => 'cu.ft',
                'description' => 'Fine aggregate for construction',
            ]);
        }

        if (!$material4) {
            $material4 = Material::create([
                'name' => 'Red Clay Bricks',
                'unit' => 'nos',
                'description' => 'Class A bricks',
            ]);
        }

        $this->command->info('Creating Material Consumption Standards...');

        // Create consumption standards (expected usage)
        $standards = [
            [
                'project_id' => $project->id,
                'material_id' => $material1->id,
                'standard_quantity' => 1000.0,
                'unit' => 'bags',
                'variance_tolerance_percentage' => 10.0,
            ],
            [
                'project_id' => $project->id,
                'material_id' => $material2->id,
                'standard_quantity' => 5000.0,
                'unit' => 'kg',
                'variance_tolerance_percentage' => 10.0,
            ],
            [
                'project_id' => $project->id,
                'material_id' => $material3->id,
                'standard_quantity' => 2000.0,
                'unit' => 'cu.ft',
                'variance_tolerance_percentage' => 10.0,
            ],
            [
                'project_id' => $project->id,
                'material_id' => $material4->id,
                'standard_quantity' => 10000.0,
                'unit' => 'nos',
                'variance_tolerance_percentage' => 10.0,
            ],
        ];

        foreach ($standards as $standard) {
            MaterialConsumptionStandard::updateOrCreate(
                [
                    'project_id' => $standard['project_id'],
                    'material_id' => $standard['material_id'],
                ],
                $standard
            );
        }

        $this->command->info('Creating Stock OUT transactions (actual consumption)...');

        // Create stock OUT transactions to simulate consumption
        // Scenario 1: Cement - EXCEEDED (120% of standard)
        $this->createStockTransactions($project->id, $material1->id, $manager->id, 1200.0);
        
        // Scenario 2: Steel - NORMAL (95% of standard, within tolerance)
        $this->createStockTransactions($project->id, $material2->id, $manager->id, 4750.0);
        
        // Scenario 3: Sand - EXCEEDED (130% of standard, high wastage)
        $this->createStockTransactions($project->id, $material3->id, $manager->id, 2600.0);
        
        // Scenario 4: Bricks - SAVINGS (80% of standard, under consumption)
        $this->createStockTransactions($project->id, $material4->id, $manager->id, 8000.0);

        $this->command->info('✅ Consumption Variance data seeded successfully!');
        $this->command->info('');
        $this->command->info('Summary:');
        $this->command->info('- Cement: 1200 bags used vs 1000 expected (20% over) ⚠️ EXCEEDED');
        $this->command->info('- Steel: 4750 kg used vs 5000 expected (5% under) ✓ NORMAL');
        $this->command->info('- Sand: 2600 cu.ft used vs 2000 expected (30% over) 🚨 EXCEEDED');
        $this->command->info('- Bricks: 8000 nos used vs 10000 expected (20% under) ✓ SAVINGS');
    }

    /**
     * Create multiple stock OUT transactions to reach the target quantity
     */
    private function createStockTransactions($projectId, $materialId, $userId, $totalQuantity)
    {
        // Split into 3-5 random transactions to simulate realistic usage
        $numTransactions = rand(3, 5);
        $remaining = $totalQuantity;

        for ($i = 0; $i < $numTransactions; $i++) {
            $quantity = ($i === $numTransactions - 1) 
                ? $remaining 
                : rand((int)($totalQuantity / $numTransactions * 0.5), (int)($totalQuantity / $numTransactions * 1.5));
            
            $remaining -= $quantity;

            StockTransaction::create([
                'project_id' => $projectId,
                'material_id' => $materialId,
                'transaction_type' => StockTransaction::TYPE_OUT,
                'quantity' => $quantity,
                'reference_type' => StockTransaction::REFERENCE_ADJUSTMENT,
                'reference_id' => 1, // Dummy reference for seeding
                'notes' => 'Material consumed for construction work',
                'performed_by' => $userId,
                'transaction_date' => now()->subDays(rand(1, 30)),
                'created_at' => now()->subDays(rand(1, 30)),
            ]);
        }
    }
}
