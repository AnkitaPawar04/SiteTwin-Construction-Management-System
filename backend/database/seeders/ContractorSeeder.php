<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Contractor;
use App\Models\ContractorTrade;

class ContractorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create contractors
        $contractors = [
            ['name' => 'Sharma Construction', 'phone' => '9876543210', 'email' => 'sharma@example.com'],
            ['name' => 'Kumar Builders', 'phone' => '9876543211', 'email' => 'kumar@example.com'],
            ['name' => 'Patel Services', 'phone' => '9876543212', 'email' => 'patel@example.com'],
            ['name' => 'Singh Contractors', 'phone' => '9876543213', 'email' => 'singh@example.com'],
            ['name' => 'Reddy Enterprises', 'phone' => '9876543214', 'email' => 'reddy@example.com'],
        ];

        foreach ($contractors as $contractorData) {
            $contractor = Contractor::create($contractorData);

            // Assign random trades to each contractor
            $trades = ['Plumbing', 'Electrical', 'Tiling', 'Painting', 'Carpentry', 'Masonry'];
            $numTrades = rand(2, 4);
            $selectedTrades = array_rand(array_flip($trades), $numTrades);

            foreach ((array)$selectedTrades as $trade) {
                ContractorTrade::create([
                    'contractor_id' => $contractor->id,
                    'trade_type' => $trade,
                ]);
            }
        }
    }
}
