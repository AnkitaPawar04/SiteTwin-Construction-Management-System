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
            'name' => 'Rajesh Kumar (Owner)',
            'phone' => '9876543210',
            'role' => 'owner',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Managers
        User::create([
            'name' => 'Amit Sharma (Manager)',
            'phone' => '9876543211',
            'role' => 'manager',
            'language' => 'en',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Priya Singh (Manager)',
            'phone' => '9876543212',
            'role' => 'manager',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Engineers
        User::create([
            'name' => 'Vikram Patel (Engineer)',
            'phone' => '9876543213',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Sneha Reddy (Engineer)',
            'phone' => '9876543214',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Arjun Menon (Engineer)',
            'phone' => '9876543215',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Workers
        $workers = [
            ['name' => 'रामू यादव', 'phone' => '9876543220', 'language' => 'hi'],
            ['name' => 'संतोष कुमार', 'phone' => '9876543221', 'language' => 'hi'],
            ['name' => 'मुकेश वर्मा', 'phone' => '9876543222', 'language' => 'hi'],
            ['name' => 'सुरेश पाल', 'phone' => '9876543223', 'language' => 'hi'],
            ['name' => 'राजेश ठाकुर', 'phone' => '9876543224', 'language' => 'hi'],
            ['name' => 'विनोद शर्मा', 'phone' => '9876543225', 'language' => 'hi'],
            ['name' => 'अजय कुमार', 'phone' => '9876543226', 'language' => 'hi'],
            ['name' => 'दिनेश प्रसाद', 'phone' => '9876543227', 'language' => 'hi'],
            ['name' => 'मनोज सिंह', 'phone' => '9876543228', 'language' => 'hi'],
            ['name' => 'संजय गुप्ता', 'phone' => '9876543229', 'language' => 'hi'],
            ['name' => 'रवि कुमार', 'phone' => '9876543230', 'language' => 'hi'],
            ['name' => 'अनिल यादव', 'phone' => '9876543231', 'language' => 'hi'],
            ['name' => 'सुनील पटेल', 'phone' => '9876543232', 'language' => 'hi'],
            ['name' => 'राकेश वर्मा', 'phone' => '9876543233', 'language' => 'hi'],
            ['name' => 'विजय सिंह', 'phone' => '9876543234', 'language' => 'hi'],
        ];

        foreach ($workers as $worker) {
            User::create([
                'name' => $worker['name'],
                'phone' => $worker['phone'],
                'role' => 'worker',
                'language' => $worker['language'],
                'is_active' => true,
            ]);
        }

        $this->command->info('Created 21 users: 1 Owner, 2 Managers, 3 Engineers, 15 Workers');
    }
}
