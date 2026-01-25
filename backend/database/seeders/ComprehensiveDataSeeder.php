<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{
    Project, User, Material, Vendor, Task, MaterialRequest, PurchaseOrder, 
    PurchaseOrderItem, Invoice, StockTransaction, ContractorRating, 
    ContractorTrade, Contractor, DailyWagerAttendance, Tool, ToolCheckout,
    PermitToWork, PettyCashTransaction, Dpr, Attendance
};
use Carbon\Carbon;

class ComprehensiveDataSeeder extends Seeder
{
    private $projects;
    private $users;
    private $materials;
    private $vendors;
    private $contractors;

    /**
     * Comprehensive data seeder to ensure all app features have realistic data
     */
    public function run(): void
    {
        $this->command->info('🎯 Running Comprehensive Data Seeder...');
        
        // Load existing data
        $this->loadExistingData();
        
        // Seed missing data for each module
        $this->seedPurchaseOrders();
        $this->seedContractorRatings();
        $this->seedDailyWagerAttendance();
        // Skipping features without matching models
        // $this->seedToolsLibrary();
        // $this->seedPermitToWork();
        // $this->seedPettyCash();
        // $this->seedAdditionalDPRs();
        // $this->seedAdditionalAttendance();
        
        $this->command->info('✅ Comprehensive data seeding completed!');
    }

    private function loadExistingData()
    {
        $this->projects = Project::all();
        $this->users = User::all();
        $this->materials = Material::all();
        $this->vendors = Vendor::all();
        $this->contractors = Contractor::all();

        if ($this->projects->isEmpty()) {
            $this->command->error('⚠️  No projects found. Run ProjectSeeder first.');
            return;
        }
    }

    /**
     * Seed complete Purchase Orders with multiple items and invoices
     */
    private function seedPurchaseOrders()
    {
        $this->command->info('  📦 Seeding Purchase Orders...');
        
        $manager = User::where('role', 'manager')->first();
        $purchaseManager = User::where('role', 'purchase_manager')->first();
        
        if (!$purchaseManager) {
            $this->command->warn('    ⚠️  No purchase manager found, skipping PO seeding');
            return;
        }

        foreach ($this->projects->take(2) as $project) {
            // Scenario 1: Completed PO with invoice and stock IN
            $this->createCompletePO($project, $purchaseManager, 'delivered', true);
            
            // Scenario 2: Approved PO pending delivery
            $this->createCompletePO($project, $purchaseManager, 'approved', false);
            
            // Scenario 3: Created PO pending approval
            $this->createCompletePO($project, $purchaseManager, 'created', false);
        }
    }

    private function createCompletePO($project, $user, $status, $withInvoice)
    {
        $vendor = $this->vendors->random();
        
        $po = PurchaseOrder::create([
            'project_id' => $project->id,
            'vendor_id' => $vendor->id,
            'created_by' => $user->id,
            'po_number' => 'PO-' . $project->id . '-' . rand(1000, 9999),
            'status' => $status,
            'approved_at' => in_array($status, ['approved', 'delivered', 'closed']) ? Carbon::now()->subDays(rand(1, 10)) : null,
            'delivered_at' => in_array($status, ['delivered', 'closed']) ? Carbon::now()->subDays(rand(1, 5)) : null,
        ]);

        // Add 2-4 items with mixed GST (to showcase mixed GST support)
        $itemCount = rand(2, 4);
        $totalAmount = 0;
        $gstAmount = 0;

        for ($i = 0; $i < $itemCount; $i++) {
            $material = $this->materials->random();
            $quantity = rand(10, 100);
            $rate = rand(50, 500);
            $subtotal = $quantity * $rate;
            
            // Mix GST and Non-GST items (based on material's GST type)
            $itemGstPercentage = $material->gst_type === 'gst' ? $material->gst_percentage : 0;
            $itemGstAmount = ($subtotal * $itemGstPercentage / 100);
            $total = $subtotal + $itemGstAmount;
            $totalAmount += $subtotal;
            $gstAmount += $itemGstAmount;

            PurchaseOrderItem::create([
                'purchase_order_id' => $po->id,
                'material_id' => $material->id,
                'quantity' => $quantity,
                'unit' => $material->unit ?? 'nos',
                'rate' => $rate,
                'amount' => $subtotal,
                'gst_percentage' => $itemGstPercentage,
                'gst_amount' => $itemGstAmount,
                'total_amount' => $total,
            ]);
        }

        $grandTotal = $totalAmount + $gstAmount;
        $po->update([
            'total_amount' => $totalAmount,
            'gst_amount' => $gstAmount,
            'grand_total' => $grandTotal,
        ]);

        // Create invoice and stock if delivered
        if ($withInvoice && in_array($status, ['approved', 'delivered', 'closed'])) {
            $invoiceNum = 'INV-' . rand(10000, 99999);
            
            $po->update([
                'invoice_number' => $invoiceNum,
                'invoice_file' => 'invoices/sample_invoice_' . $invoiceNum . '.jpg',
            ]);

            // Create stock IN transactions
            foreach ($po->items as $item) {
                StockTransaction::create([
                    'material_id' => $item->material_id,
                    'project_id' => $project->id,
                    'transaction_type' => StockTransaction::TYPE_IN,
                    'quantity' => $item->quantity,
                    'reference_type' => StockTransaction::REFERENCE_PURCHASE_ORDER,
                    'reference_id' => $po->id,
                    'performed_by' => $user->id,
                    'transaction_date' => Carbon::now()->subDays(rand(1, 5)),
                    'notes' => 'Stock IN from PO: ' . $po->po_number,
                ]);
            }
        }
    }

    /**
     * Seed contractor ratings with realistic scenarios
     */
    private function seedContractorRatings()
    {
        $this->command->info('  ⭐ Seeding Contractor Ratings...');
        
        if ($this->contractors->isEmpty()) {
            $this->command->warn('    ⚠️  No contractors found, skipping ratings');
            return;
        }

        $manager = User::where('role', 'manager')->first();
        if (!$manager) return;

        foreach ($this->contractors->take(3) as $contractor) {
            // Ensure contractor has trades
            if ($contractor->trades->isEmpty()) {
                // Add 2-3 random trades
                $tradeTypes = ['Plumbing', 'Electrical', 'Tiling', 'Painting', 'Carpentry', 'Masonry'];
                foreach (array_rand(array_flip($tradeTypes), rand(2, 3)) as $tradeType) {
                    ContractorTrade::firstOrCreate([
                        'contractor_id' => $contractor->id,
                        'trade_type' => $tradeType,
                    ]);
                }
            }

            // Rate contractor on 2-3 projects
            foreach ($this->projects->take(rand(2, 3)) as $project) {
                foreach ($contractor->trades as $trade) {
                    $speed = rand(5, 10);
                    $quality = rand(5, 10);
                    
                    ContractorRating::updateOrCreate(
                        [
                            'trade_id' => $trade->id,
                            'project_id' => $project->id,
                        ],
                        [
                            'contractor_id' => $contractor->id,
                            'speed' => $speed,
                            'quality' => $quality,
                            'rated_by' => $manager->id,
                            'comments' => 'Performance assessment for ' . $trade->trade_type,
                            'created_at' => Carbon::now()->subDays(rand(1, 30)),
                        ]
                    );
                }
            }
        }
    }

    /**
     * Seed daily wager attendance with face photos
     */
    private function seedDailyWagerAttendance()
    {
        $this->command->info('  👷 Seeding Daily Wager Attendance...');
        
        $project = $this->projects->first();
        $supervisor = User::where('role', 'manager')->first();
        if (!$supervisor) return;

        // Create 10 daily wagers with updateOrCreate to avoid duplicates
        for ($i = 1; $i <= 10; $i++) {
            $wageRate = rand(50, 150);
            $checkIn = Carbon::today()->setHour(rand(7, 9))->setMinute(rand(0, 59));
            $hasCheckedOut = rand(0, 1);
            $checkOut = $hasCheckedOut ? $checkIn->copy()->addHours(rand(8, 10)) : null;
            $hoursWorked = $hasCheckedOut ? $checkOut->diffInHours($checkIn, false) : 0;
            
            DailyWagerAttendance::updateOrCreate(
                [
                    'wager_name' => 'Daily Worker ' . $i,
                    'project_id' => $project->id,
                    'attendance_date' => Carbon::today(),
                ],
                [
                    'wager_phone' => '91' . rand(7000000000, 9999999999),
                    'check_in_time' => $checkIn,
                    'check_out_time' => $checkOut,
                    'hours_worked' => $hoursWorked,
                    'wage_rate_per_hour' => $wageRate,
                    'total_wage' => $hoursWorked * $wageRate,
                    'face_image_path' => 'faces/worker_' . $i . '.jpg',
                    'verified_by' => rand(0, 1) ? $supervisor->id : null,
                'verified_at' => rand(0, 1) ? Carbon::now() : null,
                'status' => ['PENDING', 'VERIFIED', 'REJECTED'][rand(0, 2)],
            ]);
        }
    }

    /**
     * Seed tools library with QR codes
     */
    private function seedToolsLibrary()
    {
        $this->command->info('  🔧 Seeding Tools Library...');
        
        $project = $this->projects->first();
        $workers = User::where('role', 'worker')->take(5)->get();
        if ($workers->isEmpty()) return;

        $tools = [
            ['name' => 'Drilling Machine', 'category' => 'power_tool', 'value' => 15000],
            ['name' => 'Angle Grinder', 'category' => 'power_tool', 'value' => 8000],
            ['name' => 'Concrete Mixer', 'category' => 'equipment', 'value' => 50000],
            ['name' => 'Ladder 20ft', 'category' => 'access_equipment', 'value' => 5000],
            ['name' => 'Safety Harness', 'category' => 'safety_equipment', 'value' => 3000],
            ['name' => 'Measuring Tape 100m', 'category' => 'hand_tool', 'value' => 500],
            ['name' => 'Spirit Level', 'category' => 'hand_tool', 'value' => 800],
            ['name' => 'Welding Machine', 'category' => 'power_tool', 'value' => 25000],
        ];

        foreach ($tools as $toolData) {
            $tool = Tool::create([
                'project_id' => $project->id,
                'name' => $toolData['name'],
                'category' => $toolData['category'],
                'qr_code' => 'TOOL-' . strtoupper(substr(md5($toolData['name']), 0, 8)),
                'status' => ['available', 'checked_out', 'maintenance'][rand(0, 2)],
                'condition' => ['good', 'fair', 'needs_maintenance'][rand(0, 2)],
                'purchase_date' => Carbon::now()->subMonths(rand(1, 12)),
                'value' => $toolData['value'],
                'last_maintenance_date' => rand(0, 1) ? Carbon::now()->subDays(rand(10, 60)) : null,
            ]);

            // Random checkouts
            if (rand(0, 1)) {
                $worker = $workers->random();
                ToolCheckout::create([
                    'tool_id' => $tool->id,
                    'user_id' => $worker->id,
                    'project_id' => $project->id,
                    'checked_out_at' => Carbon::now()->subDays(rand(1, 10)),
                    'expected_return_date' => Carbon::now()->addDays(rand(1, 5)),
                    'returned_at' => rand(0, 1) ? Carbon::now()->subDays(rand(0, 3)) : null,
                    'condition_at_checkout' => 'good',
                    'condition_at_return' => rand(0, 1) ? ['good', 'fair', 'damaged'][rand(0, 2)] : null,
                    'notes' => 'Tool checkout for construction work',
                ]);
            }
        }
    }

    /**
     * Seed permit to work with OTP scenarios
     */
    private function seedPermitToWork()
    {
        $this->command->info('  📋 Seeding Permit to Work...');
        
        $project = $this->projects->first();
        $workers = User::where('role', 'worker')->take(3)->get();
        $safetyOfficer = User::where('role', 'manager')->first();
        if ($workers->isEmpty() || !$safetyOfficer) return;

        $tasks = [
            ['work' => 'Demolition Work', 'risk' => 'HIGH', 'hazards' => 'Falling debris, dust'],
            ['work' => 'Electrical Wiring', 'risk' => 'CRITICAL', 'hazards' => 'Electrocution risk'],
            ['work' => 'Scaffolding Setup', 'risk' => 'MEDIUM', 'hazards' => 'Height work'],
            ['work' => 'Painting Work', 'risk' => 'LOW', 'hazards' => 'Chemical exposure'],
            ['work' => 'Welding Work', 'risk' => 'HIGH', 'hazards' => 'Fire, fumes'],
        ];

        foreach ($tasks as $taskData) {
            $worker = $workers->random();
            $isApproved = rand(0, 1);
            
            PermitToWork::create([
                'project_id' => $project->id,
                'requested_by' => $worker->id,
                'work_description' => $taskData['work'],
                'risk_level' => $taskData['risk'],
                'potential_hazards' => $taskData['hazards'],
                'safety_measures' => 'PPE required, safety briefing completed',
                'status' => $isApproved ? 'APPROVED' : ['PENDING', 'REJECTED'][rand(0, 1)],
                'otp_code' => $isApproved ? rand(100000, 999999) : null,
                'otp_expires_at' => $isApproved ? Carbon::now()->addMinutes(15) : null,
                'approved_by' => $isApproved ? $safetyOfficer->id : null,
                'approved_at' => $isApproved ? Carbon::now()->subMinutes(rand(5, 30)) : null,
                'work_started_at' => $isApproved && rand(0, 1) ? Carbon::now()->subMinutes(rand(1, 20)) : null,
                'work_completed_at' => null,
                'created_at' => Carbon::now()->subHours(rand(1, 24)),
            ]);
        }
    }

    /**
     * Seed petty cash with GPS validation
     */
    private function seedPettyCash()
    {
        $this->command->info('  💰 Seeding Petty Cash Transactions...');
        
        $project = $this->projects->first();
        $engineers = User::where('role', 'engineer')->take(3)->get();
        $manager = User::where('role', 'manager')->first();
        if ($engineers->isEmpty() || !$manager) return;

        $expenses = [
            ['desc' => 'Worker lunch', 'amount' => 500, 'category' => 'MEALS'],
            ['desc' => 'Taxi for material pickup', 'amount' => 350, 'category' => 'TRANSPORT'],
            ['desc' => 'Small hardware items', 'amount' => 750, 'category' => 'MATERIALS'],
            ['desc' => 'Courier charges', 'amount' => 200, 'category' => 'MISCELLANEOUS'],
            ['desc' => 'Drinking water bottles', 'amount' => 300, 'category' => 'SUPPLIES'],
        ];

        foreach ($expenses as $expenseData) {
            $engineer = $engineers->random();
            $isApproved = rand(0, 1);
            
            PettyCashTransaction::create([
                'project_id' => $project->id,
                'user_id' => $engineer->id,
                'amount' => $expenseData['amount'],
                'category' => $expenseData['category'],
                'description' => $expenseData['desc'],
                'receipt_image_path' => 'receipts/receipt_' . rand(1000, 9999) . '.jpg',
                'gps_latitude' => 18.5204 + (rand(-100, 100) / 10000), // Near Pune
                'gps_longitude' => 73.8567 + (rand(-100, 100) / 10000),
                'status' => $isApproved ? 'APPROVED' : ['PENDING', 'REJECTED'][rand(0, 1)],
                'approved_by' => $isApproved ? $manager->id : null,
                'approved_at' => $isApproved ? Carbon::now()->subDays(rand(1, 5)) : null,
                'payment_method' => ['CASH', 'UPI', 'CARD'][rand(0, 2)],
                'created_at' => Carbon::now()->subDays(rand(1, 10)),
            ]);
        }
    }

    /**
     * Seed additional DPRs for recent dates
     */
    private function seedAdditionalDPRs()
    {
        $this->command->info('  📝 Seeding Additional DPRs...');
        
        $workers = User::where('role', 'worker')->take(5)->get();
        if ($workers->isEmpty()) return;

        foreach ($this->projects->take(2) as $project) {
            foreach ($workers as $worker) {
                // Create DPRs for last 5 days
                for ($day = 0; $day < 5; $day++) {
                    $date = Carbon::now()->subDays($day);
                    
                    Dpr::create([
                        'project_id' => $project->id,
                        'user_id' => $worker->id,
                        'work_description' => 'Daily work completed: ' . ['Brickwork', 'Plastering', 'Painting', 'Electrical'][rand(0, 3)],
                        'hours_worked' => rand(7, 9),
                        'materials_used' => json_encode([
                            ['material' => 'Cement', 'quantity' => rand(2, 10)],
                            ['material' => 'Sand', 'quantity' => rand(5, 20)],
                        ]),
                        'status' => ['PENDING', 'APPROVED', 'REJECTED'][rand(0, 2)],
                        'gps_latitude' => 18.5204 + (rand(-10, 10) / 1000),
                        'gps_longitude' => 73.8567 + (rand(-10, 10) / 1000),
                        'photos' => json_encode(['dpr/photo1.jpg', 'dpr/photo2.jpg']),
                        'created_at' => $date,
                    ]);
                }
            }
        }
    }

    /**
     * Seed additional attendance records
     */
    private function seedAdditionalAttendance()
    {
        $this->command->info('  📅 Seeding Additional Attendance...');
        
        $workers = User::where('role', 'worker')->get();
        $engineers = User::where('role', 'engineer')->get();
        
        $allUsers = $workers->merge($engineers);
        if ($allUsers->isEmpty()) return;

        foreach ($this->projects->take(2) as $project) {
            foreach ($allUsers as $user) {
                // Create attendance for last 7 days
                for ($day = 0; $day < 7; $day++) {
                    $date = Carbon::now()->subDays($day);
                    
                    // Skip some random days (not perfect attendance)
                    if (rand(0, 10) > 8) continue;
                    
                    $checkIn = $date->copy()->setHour(rand(7, 9))->setMinute(rand(0, 59));
                    $checkOut = $checkIn->copy()->addHours(rand(8, 10));
                    
                    Attendance::create([
                        'user_id' => $user->id,
                        'project_id' => $project->id,
                        'check_in' => $checkIn,
                        'check_out' => rand(0, 1) ? $checkOut : null, // Some still working
                        'status' => ['PRESENT', 'PRESENT', 'HALF_DAY'][rand(0, 2)],
                        'gps_latitude' => 18.5204 + (rand(-10, 10) / 1000),
                        'gps_longitude' => 73.8567 + (rand(-10, 10) / 1000),
                    ]);
                }
            }
        }
    }
}
