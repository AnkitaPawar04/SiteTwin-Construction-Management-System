<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Tool;
use App\Models\Project;
use App\Models\User;
use Carbon\Carbon;

class ToolSeeder extends Seeder
{
    /**
     * Run the database seeder.
     */
    public function run(): void
    {
        $projects = Project::all();
        $engineers = User::whereIn('role', ['engineer', 'site_engineer', 'manager'])->get();

        $tools = [
            // Electrical Tools
            [
                'tool_name' => 'Electric Drill Machine - 13mm',
                'category' => 'ELECTRICAL',
                'purchase_price' => 3500.00,
                'condition' => 'EXCELLENT',
                'description' => 'High-speed electric drill with 13mm chuck capacity, 550W motor',
            ],
            [
                'tool_name' => 'Angle Grinder - 4 inch',
                'category' => 'ELECTRICAL',
                'purchase_price' => 2800.00,
                'condition' => 'GOOD',
                'description' => '850W angle grinder for cutting and grinding',
            ],
            [
                'tool_name' => 'Circular Saw - 7 inch',
                'category' => 'ELECTRICAL',
                'purchase_price' => 4200.00,
                'condition' => 'EXCELLENT',
                'description' => 'Professional grade circular saw for wood cutting',
            ],
            [
                'tool_name' => 'Electric Planer',
                'category' => 'ELECTRICAL',
                'purchase_price' => 5500.00,
                'condition' => 'GOOD',
                'description' => '82mm electric planer for wood finishing',
            ],
            [
                'tool_name' => 'Impact Driver',
                'category' => 'ELECTRICAL',
                'purchase_price' => 6500.00,
                'condition' => 'EXCELLENT',
                'description' => 'Cordless impact driver with battery and charger',
            ],

            // Hand Tools
            [
                'tool_name' => 'Spirit Level - 24 inch',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 450.00,
                'condition' => 'EXCELLENT',
                'description' => 'Aluminum spirit level with magnetic base',
            ],
            [
                'tool_name' => 'Measuring Tape - 7.5m',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 280.00,
                'condition' => 'GOOD',
                'description' => 'Professional steel measuring tape',
            ],
            [
                'tool_name' => 'Hammer - 500g',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 320.00,
                'condition' => 'GOOD',
                'description' => 'Claw hammer with fiberglass handle',
            ],
            [
                'tool_name' => 'Screwdriver Set - 8 pieces',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 550.00,
                'condition' => 'EXCELLENT',
                'description' => 'Professional screwdriver set with magnetic tips',
            ],
            [
                'tool_name' => 'Adjustable Wrench - 12 inch',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 380.00,
                'condition' => 'GOOD',
                'description' => 'Chrome vanadium adjustable wrench',
            ],
            [
                'tool_name' => 'Pliers Set - 3 pieces',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 650.00,
                'condition' => 'EXCELLENT',
                'description' => 'Combination, needle nose, and cutting pliers',
            ],
            [
                'tool_name' => 'Hand Saw - 22 inch',
                'category' => 'HAND_TOOLS',
                'purchase_price' => 420.00,
                'condition' => 'GOOD',
                'description' => 'Professional hand saw for wood cutting',
            ],

            // Safety Equipment
            [
                'tool_name' => 'Safety Helmet - Type A',
                'category' => 'SAFETY',
                'purchase_price' => 280.00,
                'condition' => 'EXCELLENT',
                'description' => 'ABS safety helmet with adjustable ratchet',
            ],
            [
                'tool_name' => 'Safety Harness - Full Body',
                'category' => 'SAFETY',
                'purchase_price' => 1800.00,
                'condition' => 'EXCELLENT',
                'description' => 'Full body harness for working at heights',
            ],
            [
                'tool_name' => 'Safety Goggles - Clear',
                'category' => 'SAFETY',
                'purchase_price' => 120.00,
                'condition' => 'GOOD',
                'description' => 'Anti-fog safety goggles with UV protection',
            ],
            [
                'tool_name' => 'Ear Muffs - Noise Cancelling',
                'category' => 'SAFETY',
                'purchase_price' => 450.00,
                'condition' => 'EXCELLENT',
                'description' => 'NRR 31dB noise cancelling ear muffs',
            ],
            [
                'tool_name' => 'Safety Gloves - Leather',
                'category' => 'SAFETY',
                'purchase_price' => 180.00,
                'condition' => 'GOOD',
                'description' => 'Premium leather work gloves',
            ],

            // Carpentry Tools
            [
                'tool_name' => 'Wood Chisel Set - 6 pieces',
                'category' => 'CARPENTRY',
                'purchase_price' => 850.00,
                'condition' => 'EXCELLENT',
                'description' => 'Professional wood chisel set 6mm to 25mm',
            ],
            [
                'tool_name' => 'Carpenter Square - 12 inch',
                'category' => 'CARPENTRY',
                'purchase_price' => 320.00,
                'condition' => 'GOOD',
                'description' => 'Steel carpenter square for accurate marking',
            ],
            [
                'tool_name' => 'Wood Plane - Block Type',
                'category' => 'CARPENTRY',
                'purchase_price' => 680.00,
                'condition' => 'EXCELLENT',
                'description' => 'Cast iron block plane for fine woodworking',
            ],
            [
                'tool_name' => 'Miter Box with Saw',
                'category' => 'CARPENTRY',
                'purchase_price' => 950.00,
                'condition' => 'GOOD',
                'description' => 'Precision miter box for angled cuts',
            ],

            // Masonry Tools
            [
                'tool_name' => 'Trowel - Brick',
                'category' => 'MASONRY',
                'purchase_price' => 280.00,
                'condition' => 'GOOD',
                'description' => 'Professional brick laying trowel',
            ],
            [
                'tool_name' => 'Float - Plastering',
                'category' => 'MASONRY',
                'purchase_price' => 320.00,
                'condition' => 'EXCELLENT',
                'description' => 'Stainless steel plastering float',
            ],
            [
                'tool_name' => 'Spirit Level - Mason\'s 4ft',
                'category' => 'MASONRY',
                'purchase_price' => 850.00,
                'condition' => 'EXCELLENT',
                'description' => 'Heavy duty mason\'s level',
            ],
            [
                'tool_name' => 'Concrete Mixer - Portable',
                'category' => 'MASONRY',
                'purchase_price' => 12500.00,
                'condition' => 'GOOD',
                'description' => 'Electric concrete mixer 120L capacity',
            ],

            // Measuring & Testing
            [
                'tool_name' => 'Laser Distance Meter',
                'category' => 'MEASURING',
                'purchase_price' => 3200.00,
                'condition' => 'EXCELLENT',
                'description' => 'Digital laser distance meter up to 40m',
            ],
            [
                'tool_name' => 'Digital Multimeter',
                'category' => 'MEASURING',
                'purchase_price' => 1200.00,
                'condition' => 'EXCELLENT',
                'description' => 'Professional digital multimeter with auto-ranging',
            ],
            [
                'tool_name' => 'Moisture Meter',
                'category' => 'MEASURING',
                'purchase_price' => 1800.00,
                'condition' => 'GOOD',
                'description' => 'Digital moisture meter for concrete and wood',
            ],
            [
                'tool_name' => 'Thermal Camera',
                'category' => 'MEASURING',
                'purchase_price' => 25000.00,
                'condition' => 'EXCELLENT',
                'description' => 'Infrared thermal imaging camera for inspection',
            ],

            // Ladders & Scaffolding
            [
                'tool_name' => 'Extension Ladder - 20ft',
                'category' => 'LADDERS',
                'purchase_price' => 4500.00,
                'condition' => 'GOOD',
                'description' => 'Aluminum extension ladder with safety locks',
            ],
            [
                'tool_name' => 'Step Ladder - 6ft',
                'category' => 'LADDERS',
                'purchase_price' => 2200.00,
                'condition' => 'EXCELLENT',
                'description' => 'Fiberglass step ladder with tool tray',
            ],
            [
                'tool_name' => 'Scaffolding Frame - 6ft',
                'category' => 'LADDERS',
                'purchase_price' => 3800.00,
                'condition' => 'GOOD',
                'description' => 'Steel scaffolding frame with cross braces',
            ],
        ];

        $toolNumber = 1;
        $purchaseDate = Carbon::now()->subMonths(rand(1, 24));

        foreach ($tools as $toolData) {
            $toolCode = 'TOOL-' . str_pad($toolNumber, 4, '0', STR_PAD_LEFT);
            $qrCode = 'QR-' . $toolCode;

            // Randomly assign some tools as checked out
            $isCheckedOut = rand(1, 100) <= 30; // 30% chance of being checked out
            $needsMaintenance = rand(1, 100) <= 10; // 10% chance of maintenance
            
            $status = 'AVAILABLE';
            $holderId = null;
            $projectId = null;

            if ($needsMaintenance) {
                $status = 'MAINTENANCE';
            } elseif ($isCheckedOut && $engineers->isNotEmpty() && $projects->isNotEmpty()) {
                $status = 'CHECKED_OUT';
                $holderId = $engineers->random()->id;
                $projectId = $projects->random()->id;
            }

            Tool::create([
                'tool_name' => $toolData['tool_name'],
                'tool_code' => $toolCode,
                'qr_code' => $qrCode,
                'category' => $toolData['category'],
                'current_status' => $status,
                'current_holder_id' => $holderId,
                'current_project_id' => $projectId,
                'purchase_date' => $purchaseDate->copy()->addDays(rand(0, 365)),
                'purchase_price' => $toolData['purchase_price'],
                'condition' => $toolData['condition'],
                'description' => $toolData['description'],
            ]);

            $toolNumber++;
        }

        $this->command->info('Created ' . count($tools) . ' tools in the library');
        $this->command->info('Tools by status:');
        $this->command->info('  - Available: ' . Tool::where('current_status', 'AVAILABLE')->count());
        $this->command->info('  - Checked Out: ' . Tool::where('current_status', 'CHECKED_OUT')->count());
        $this->command->info('  - Maintenance: ' . Tool::where('current_status', 'MAINTENANCE')->count());
    }
}
