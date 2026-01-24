<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run()
    {
        // Owner
        User::create([
            'name' => 'Shubham Shinde',
            'phone' => '9876543210',
            'role' => 'owner',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Manager
        User::create([
            'name' => 'Amit Sharma',
            'phone' => '9876543211',
            'role' => 'manager',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Engineer
        User::create([
            'name' => 'Vikram Patel',
            'phone' => '9876543213',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Worker
        User::create([
            'name' => 'Ramu Yadav',
            'phone' => '9876543220',
            'role' => 'worker',
            'language' => 'en',
            'is_active' => true,
        ]);

        $this->command->info('Created 4 users: 1 Owner, 1 Manager, 1 Engineer, 1 Worker');
    }
}
