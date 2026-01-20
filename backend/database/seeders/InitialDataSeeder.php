<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Material;
use Illuminate\Database\Seeder;

class InitialDataSeeder extends Seeder
{
    public function run()
    {
        // Create Owner
        User::create([
            'name' => 'Owner User',
            'phone' => '9999999999',
            'role' => 'owner',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Manager
        User::create([
            'name' => 'Manager User',
            'phone' => '9999999998',
            'role' => 'manager',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Engineer
        User::create([
            'name' => 'Engineer User',
            'phone' => '9999999997',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Worker
        User::create([
            'name' => 'Worker User',
            'phone' => '9999999996',
            'role' => 'worker',
            'language' => 'hi',
            'is_active' => true,
        ]);

        // Create Materials
        $materials = [
            ['name' => 'Cement (OPC 53)', 'unit' => 'bag', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (8mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (12mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (16mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Sand', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Aggregate (20mm)', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Bricks', 'unit' => 'piece', 'gst_percentage' => 12],
            ['name' => 'Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Tiles', 'unit' => 'sq ft', 'gst_percentage' => 18],
            ['name' => 'Electrical Wire', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'Plumbing Pipes', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'Concrete Mix', 'unit' => 'cubic meter', 'gst_percentage' => 18],
        ];

        foreach ($materials as $material) {
            Material::create($material);
        }

        $this->command->info('Initial data seeded successfully!');
        $this->command->info('Test Users Created:');
        $this->command->info('- Owner: 9999999999');
        $this->command->info('- Manager: 9999999998');
        $this->command->info('- Engineer: 9999999997');
        $this->command->info('- Worker: 9999999996');
    }
}
