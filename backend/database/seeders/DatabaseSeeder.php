<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🌱 Seeding Construction Management Database...');
        $this->command->newLine();

        $this->call([
            UserSeeder::class,
            MaterialSeeder::class,
            VendorSeeder::class,
            ProjectSeeder::class,
            AttendanceSeeder::class,
            TaskSeeder::class,
            DprSeeder::class,
            MaterialRequestSeeder::class,
            StockSeeder::class,
            InvoiceSeeder::class,
            NotificationSeeder::class,
        ]);

        $this->command->newLine();
        $this->command->info('✅ Database seeding completed successfully!');
        $this->command->newLine();
        $this->command->info('📱 Test Login Credentials:');
        $this->command->info('   Owner:    9876543210');
        $this->command->info('   Manager:  9876543211 or 9876543212');
        $this->command->info('   Engineer: 9876543213, 9876543214, or 9876543215');
        $this->command->info('   Worker:   9876543220 to 9876543234');
        $this->command->newLine();
    }
}
