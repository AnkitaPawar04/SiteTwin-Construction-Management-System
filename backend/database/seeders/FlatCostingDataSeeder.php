<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Project;
use App\Models\ProjectUnit;
use Carbon\Carbon;

class FlatCostingDataSeeder extends Seeder
{
    /**
     * Seed dummy data for flat costing:
     * - Project units (flats) with sold/unsold status
     * - Daily wager attendance (labor costs)
     * - Petty cash transactions (misc expenses)
     */
    public function run(): void
    {
        $projects = Project::all();

        if ($projects->isEmpty()) {
            $this->command->warn('No projects found. Please seed projects first.');
            return;
        }

        foreach ($projects as $project) {
            $this->command->info("Seeding flat costing data for: {$project->name}");

            // 1. Create project units (flats)
            $this->seedProjectUnits($project);

            // 2. Create daily wager attendance (labor costs)
            $this->seedLaborCosts($project);

            // 3. Create petty cash transactions (misc expenses)
            $this->seedMiscExpenses($project);
        }

        $this->command->info('Flat costing data seeded successfully!');
    }

    private function seedProjectUnits(Project $project): void
    {
        // Check if units already exist
        $existingUnits = ProjectUnit::where('project_id', $project->id)->count();
        
        if ($existingUnits > 0) {
            $this->command->warn("  - Skipping units (already exist: {$existingUnits} units)");
            return;
        }

        // Create 100 flats, 60% sold, 40% unsold
        $totalFlats = 100;
        $soldCount = 60;

        for ($i = 1; $i <= $totalFlats; $i++) {
            $isSold = $i <= $soldCount;
            
            ProjectUnit::create([
                'project_id' => $project->id,
                'unit_number' => "FLAT-{$i}",
                'unit_type' => $i <= 30 ? '2BHK' : ($i <= 70 ? '3BHK' : '4BHK'),
                'floor_area' => rand(800, 2000),
                'floor_area_unit' => 'sqft',
                'is_sold' => $isSold,
                'sold_price' => $isSold ? rand(3000000, 8000000) : null,
                'sold_date' => $isSold ? Carbon::now()->subDays(rand(30, 180)) : null,
                'buyer_name' => $isSold ? "Buyer {$i}" : null,
                'description' => "Residential flat unit {$i}",
            ]);
        }

        $this->command->info("  - Created {$totalFlats} flats ({$soldCount} sold, " . ($totalFlats - $soldCount) . " unsold)");
    }

    private function seedLaborCosts(Project $project): void
    {
        // Check if labor costs already exist
        $existingLabor = DB::table('daily_wager_attendance')
            ->where('project_id', $project->id)
            ->count();

        if ($existingLabor > 0) {
            $this->command->warn("  - Skipping labor costs (already exist: {$existingLabor} records)");
            return;
        }

        // Create labor entries for past 3 months
        $startDate = Carbon::now()->subMonths(3);
        $totalAmount = 0;
        $recordCount = 0;

        // 20 workers, working 60 days (3 months)
        $workers = [
            ['name' => 'Raju Kumar', 'rate' => 500],
            ['name' => 'Suresh Yadav', 'rate' => 550],
            ['name' => 'Prakash Singh', 'rate' => 600],
            ['name' => 'Ramesh Patel', 'rate' => 450],
            ['name' => 'Vijay Sharma', 'rate' => 500],
            ['name' => 'Manoj Gupta', 'rate' => 550],
            ['name' => 'Sanjay Verma', 'rate' => 600],
            ['name' => 'Anil Kumar', 'rate' => 500],
            ['name' => 'Rakesh Singh', 'rate' => 550],
            ['name' => 'Deepak Yadav', 'rate' => 500],
            ['name' => 'Mukesh Kumar', 'rate' => 450],
            ['name' => 'Rajesh Patel', 'rate' => 500],
            ['name' => 'Ashok Sharma', 'rate' => 550],
            ['name' => 'Dinesh Gupta', 'rate' => 600],
            ['name' => 'Kiran Singh', 'rate' => 500],
            ['name' => 'Mohan Yadav', 'rate' => 550],
            ['name' => 'Pawan Kumar', 'rate' => 500],
            ['name' => 'Ramesh Verma', 'rate' => 450],
            ['name' => 'Sunil Patel', 'rate' => 500],
            ['name' => 'Vinod Sharma', 'rate' => 550],
        ];

        for ($day = 0; $day < 60; $day++) {
            $date = $startDate->copy()->addDays($day);
            
            // Skip Sundays
            if ($date->dayOfWeek == 0) continue;

            foreach ($workers as $worker) {
                // Random attendance (80% attendance rate)
                if (rand(1, 10) <= 8) {
                    $hoursWorked = 8.0;
                    $wage = $hoursWorked * $worker['rate'];
                    
                    DB::table('daily_wager_attendance')->insert([
                        'wager_name' => $worker['name'],
                        'wager_phone' => '98' . rand(10000000, 99999999),
                        'project_id' => $project->id,
                        'attendance_date' => $date->format('Y-m-d'),
                        'check_in_time' => $date->format('Y-m-d') . ' 08:00:00',
                        'check_out_time' => $date->format('Y-m-d') . ' 17:00:00',
                        'hours_worked' => $hoursWorked,
                        'wage_rate_per_hour' => $worker['rate'],
                        'total_wage' => $wage,
                        'verified_by' => 1,
                        'verified_at' => $date->format('Y-m-d H:i:s'),
                        'status' => 'VERIFIED',
                        'created_at' => $date,
                        'updated_at' => $date,
                    ]);

                    $totalAmount += $wage;
                    $recordCount++;
                }
            }
        }

        $this->command->info("  - Created {$recordCount} labor records (Total: ₹" . number_format($totalAmount) . ")");
    }

    private function seedMiscExpenses(Project $project): void
    {
        // Check if misc expenses already exist
        $existingExpenses = DB::table('petty_cash_transactions')
            ->where('project_id', $project->id)
            ->count();

        if ($existingExpenses > 0) {
            $this->command->warn("  - Skipping misc expenses (already exist: {$existingExpenses} records)");
            return;
        }

        // Create misc expenses for past 3 months
        $startDate = Carbon::now()->subMonths(3);
        $totalAmount = 0;
        $recordCount = 0;

        $expenseTypes = [
            ['purpose' => 'Tea & Snacks for Workers', 'min' => 500, 'max' => 1500],
            ['purpose' => 'Tools & Equipment Rental', 'min' => 2000, 'max' => 5000],
            ['purpose' => 'Transportation', 'min' => 1000, 'max' => 3000],
            ['purpose' => 'Safety Equipment', 'min' => 1500, 'max' => 4000],
            ['purpose' => 'Cleaning Supplies', 'min' => 500, 'max' => 2000],
            ['purpose' => 'Minor Repairs', 'min' => 1000, 'max' => 5000],
            ['purpose' => 'Electricity Bill', 'min' => 3000, 'max' => 8000],
            ['purpose' => 'Water Bill', 'min' => 2000, 'max' => 5000],
            ['purpose' => 'Site Security', 'min' => 5000, 'max' => 10000],
            ['purpose' => 'Office Supplies', 'min' => 500, 'max' => 2000],
        ];

        // Add 3-5 expenses per week
        for ($week = 0; $week < 12; $week++) {
            $expensesThisWeek = rand(3, 5);
            
            for ($i = 0; $i < $expensesThisWeek; $i++) {
                $expense = $expenseTypes[array_rand($expenseTypes)];
                $amount = rand($expense['min'], $expense['max']);
                $date = $startDate->copy()->addWeeks($week)->addDays(rand(0, 6));

                DB::table('petty_cash_transactions')->insert([
                    'project_id' => $project->id,
                    'amount' => $amount,
                    'purpose' => $expense['purpose'],
                    'description' => $expense['purpose'] . ' - ' . $date->format('M d, Y'),
                    'transaction_date' => $date->format('Y-m-d'),
                    'requested_by' => 1,
                    'requested_at' => $date->format('Y-m-d H:i:s'),
                    'approved_by' => 1,
                    'approved_at' => $date->format('Y-m-d H:i:s'),
                    'payment_method' => rand(0, 1) ? 'CASH' : 'UPI',
                    'status' => 'APPROVED',
                    'gps_validated' => true,
                    'created_at' => $date,
                    'updated_at' => $date,
                ]);

                $totalAmount += $amount;
                $recordCount++;
            }
        }

        $this->command->info("  - Created {$recordCount} misc expense records (Total: ₹" . number_format($totalAmount) . ")");
    }
}
