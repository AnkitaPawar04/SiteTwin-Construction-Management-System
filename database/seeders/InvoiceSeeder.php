<?php

namespace Database\Seeders;

use App\Models\Invoice;
use App\Models\InvoiceItem;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class InvoiceSeeder extends Seeder
{
    public function run()
    {
        // Invoice 1 - Project 1 - Foundation Work
        $invoice1 = Invoice::create([
            'project_id' => 1,
            'invoice_number' => 'INV-20260110-0001',
            'total_amount' => 0,
            'gst_amount' => 0,
            'status' => 'paid',
            'created_at' => Carbon::parse('2026-01-10'),
        ]);

        $items1 = [
            ['description' => 'Foundation Excavation - Block A', 'amount' => 150000, 'gst_percentage' => 18],
            ['description' => 'Steel Reinforcement - Ground Floor', 'amount' => 250000, 'gst_percentage' => 18],
            ['description' => 'Concrete Work - Foundation & Slab', 'amount' => 350000, 'gst_percentage' => 18],
            ['description' => 'Labor Charges - Foundation Work', 'amount' => 120000, 'gst_percentage' => 18],
        ];

        $total1 = 0;
        $gst1 = 0;

        foreach ($items1 as $item) {
            InvoiceItem::create([
                'invoice_id' => $invoice1->id,
                'description' => $item['description'],
                'amount' => $item['amount'],
                'gst_percentage' => $item['gst_percentage'],
            ]);
            $total1 += $item['amount'];
            $gst1 += ($item['amount'] * $item['gst_percentage']) / 100;
        }

        $invoice1->update([
            'total_amount' => $total1 + $gst1,
            'gst_amount' => $gst1,
        ]);

        // Invoice 2 - Project 1 - Brickwork & Masonry
        $invoice2 = Invoice::create([
            'project_id' => 1,
            'invoice_number' => 'INV-20260115-0002',
            'total_amount' => 0,
            'gst_amount' => 0,
            'status' => 'paid',
            'created_at' => Carbon::parse('2026-01-15'),
        ]);

        $items2 = [
            ['description' => 'Brickwork - External Walls', 'amount' => 180000, 'gst_percentage' => 12],
            ['description' => 'Internal Partition Walls', 'amount' => 120000, 'gst_percentage' => 12],
            ['description' => 'Plastering Work - Rough', 'amount' => 90000, 'gst_percentage' => 18],
            ['description' => 'Mason Labor Charges', 'amount' => 85000, 'gst_percentage' => 18],
        ];

        $total2 = 0;
        $gst2 = 0;

        foreach ($items2 as $item) {
            InvoiceItem::create([
                'invoice_id' => $invoice2->id,
                'description' => $item['description'],
                'amount' => $item['amount'],
                'gst_percentage' => $item['gst_percentage'],
            ]);
            $total2 += $item['amount'];
            $gst2 += ($item['amount'] * $item['gst_percentage']) / 100;
        }

        $invoice2->update([
            'total_amount' => $total2 + $gst2,
            'gst_amount' => $gst2,
        ]);

        // Invoice 3 - Project 2 - Site Preparation
        $invoice3 = Invoice::create([
            'project_id' => 2,
            'invoice_number' => 'INV-20260118-0003',
            'total_amount' => 0,
            'gst_amount' => 0,
            'status' => 'generated',
            'created_at' => Carbon::parse('2026-01-18'),
        ]);

        $items3 = [
            ['description' => 'Site Clearing & Leveling', 'amount' => 80000, 'gst_percentage' => 18],
            ['description' => 'Soil Testing & Survey', 'amount' => 45000, 'gst_percentage' => 18],
            ['description' => 'Excavation Work - Phase 1', 'amount' => 220000, 'gst_percentage' => 18],
            ['description' => 'Dewatering Equipment Rental', 'amount' => 35000, 'gst_percentage' => 18],
        ];

        $total3 = 0;
        $gst3 = 0;

        foreach ($items3 as $item) {
            InvoiceItem::create([
                'invoice_id' => $invoice3->id,
                'description' => $item['description'],
                'amount' => $item['amount'],
                'gst_percentage' => $item['gst_percentage'],
            ]);
            $total3 += $item['amount'];
            $gst3 += ($item['amount'] * $item['gst_percentage']) / 100;
        }

        $invoice3->update([
            'total_amount' => $total3 + $gst3,
            'gst_amount' => $gst3,
        ]);

        // Invoice 4 - Project 1 - Electrical & Plumbing
        $invoice4 = Invoice::create([
            'project_id' => 1,
            'invoice_number' => 'INV-20260120-0004',
            'total_amount' => 0,
            'gst_amount' => 0,
            'status' => 'generated',
            'created_at' => Carbon::now(),
        ]);

        $items4 = [
            ['description' => 'Electrical Conduit Installation', 'amount' => 75000, 'gst_percentage' => 18],
            ['description' => 'Plumbing Rough-in Work', 'amount' => 95000, 'gst_percentage' => 18],
            ['description' => 'Electrical Materials Supply', 'amount' => 120000, 'gst_percentage' => 18],
            ['description' => 'Plumbing Materials Supply', 'amount' => 85000, 'gst_percentage' => 18],
        ];

        $total4 = 0;
        $gst4 = 0;

        foreach ($items4 as $item) {
            InvoiceItem::create([
                'invoice_id' => $invoice4->id,
                'description' => $item['description'],
                'amount' => $item['amount'],
                'gst_percentage' => $item['gst_percentage'],
            ]);
            $total4 += $item['amount'];
            $gst4 += ($item['amount'] * $item['gst_percentage']) / 100;
        }

        $invoice4->update([
            'total_amount' => $total4 + $gst4,
            'gst_amount' => $gst4,
        ]);

        $this->command->info('Created 4 invoices with line items (2 paid, 2 pending)');
    }
}
