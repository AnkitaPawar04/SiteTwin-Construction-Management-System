<?php

namespace Database\Seeders;

use App\Models\Vendor;
use Illuminate\Database\Seeder;

class VendorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $vendors = [
            [
                'name' => 'ABC Suppliers Pvt Ltd',
                'contact_person' => 'Rajesh Kumar',
                'phone' => '9876543210',
                'email' => 'rajesh@abcsuppliers.com',
                'address' => 'Plot 123, Industrial Area, Phase 1, Mumbai',
                'gst_number' => '27AABCU9603R1ZX',
                'is_active' => true,
            ],
            [
                'name' => 'XYZ Construction Materials',
                'contact_person' => 'Amit Sharma',
                'phone' => '9123456789',
                'email' => 'amit@xyzconstruction.com',
                'address' => '45, Building Materials Market, Pune',
                'gst_number' => '27AACFX1234E1Z5',
                'is_active' => true,
            ],
            [
                'name' => 'Local Sand Supplier',
                'contact_person' => 'Suresh Patil',
                'phone' => '9999888877',
                'address' => 'Village Road, Taluka Area',
                'is_active' => true,
            ],
            [
                'name' => 'Premium Steel Traders',
                'contact_person' => 'Vikram Singh',
                'phone' => '9876512345',
                'email' => 'vikram@premiumsteel.com',
                'address' => 'Steel Market, Sector 15, Delhi',
                'gst_number' => '07AACFP1234K1ZL',
                'is_active' => true,
            ],
            [
                'name' => 'Cement Wholesale Depot',
                'contact_person' => 'Ramesh Gupta',
                'phone' => '9123498765',
                'email' => 'ramesh@cementwholesale.com',
                'address' => 'Warehouse 12, Industrial Zone, Bangalore',
                'gst_number' => '29AABCC1234D1ZP',
                'is_active' => true,
            ],
        ];

        foreach ($vendors as $vendorData) {
            Vendor::create($vendorData);
        }

        $this->command->info('✅ Vendors seeded successfully');
    }
}
