<?php

namespace Database\Seeders;

use App\Models\MaterialRequest;
use App\Models\MaterialRequestItem;
use App\Models\Approval;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class MaterialRequestSeeder extends Seeder
{
    public function run()
    {
        // Approved Material Requests
        $request1 = MaterialRequest::create([
            'project_id' => 1,
            'requested_by' => 3, // Engineer Vikram
            'approved_by' => 2, // Manager Amit
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(9),
        ]);

        MaterialRequestItem::create(['request_id' => $request1->id, 'material_id' => 1, 'quantity' => 200]); // Cement
        MaterialRequestItem::create(['request_id' => $request1->id, 'material_id' => 5, 'quantity' => 5000]); // Steel 8mm
        MaterialRequestItem::create(['request_id' => $request1->id, 'material_id' => 11, 'quantity' => 50]); // Sand

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request1->id,
            'approved_by' => 2,
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(9)->addHours(2),
        ]);

        $request2 = MaterialRequest::create([
            'project_id' => 1,
            'requested_by' => 4, // Worker Ramu
            'approved_by' => 2,
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(6),
        ]);

        MaterialRequestItem::create(['request_id' => $request2->id, 'material_id' => 15, 'quantity' => 10000]); // Red Bricks
        MaterialRequestItem::create(['request_id' => $request2->id, 'material_id' => 1, 'quantity' => 100]); // Cement
        MaterialRequestItem::create(['request_id' => $request2->id, 'material_id' => 11, 'quantity' => 30]); // Sand

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request2->id,
            'approved_by' => 2,
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(6)->addHours(1),
        ]);

        $request3 = MaterialRequest::create([
            'project_id' => 2,
            'requested_by' => 3, // Engineer Vikram
            'approved_by' => 2, // Manager Amit
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(7),
        ]);

        MaterialRequestItem::create(['request_id' => $request3->id, 'material_id' => 1, 'quantity' => 150]);
        MaterialRequestItem::create(['request_id' => $request3->id, 'material_id' => 7, 'quantity' => 3000]); // Steel 12mm
        MaterialRequestItem::create(['request_id' => $request3->id, 'material_id' => 13, 'quantity' => 40]); // Aggregate

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request3->id,
            'approved_by' => 2,
            'status' => 'approved',
            'created_at' => Carbon::now()->subDays(7)->addHours(3),
        ]);

        // Pending Material Requests
        $request4 = MaterialRequest::create([
            'project_id' => 1,
            'requested_by' => 3,
            'status' => 'pending',
            'created_at' => Carbon::now()->subDays(2),
        ]);

        MaterialRequestItem::create(['request_id' => $request4->id, 'material_id' => 33, 'quantity' => 500]); // Electrical Wire
        MaterialRequestItem::create(['request_id' => $request4->id, 'material_id' => 35, 'quantity' => 20]); // MCB 16A
        MaterialRequestItem::create(['request_id' => $request4->id, 'material_id' => 38, 'quantity' => 50]); // Switches

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request4->id,
            'status' => 'pending',
            'created_at' => Carbon::now()->subDays(2),
        ]);

        $request5 = MaterialRequest::create([
            'project_id' => 1,
            'requested_by' => 4,
            'status' => 'pending',
            'created_at' => Carbon::now()->subDays(1),
        ]);

        MaterialRequestItem::create(['request_id' => $request5->id, 'material_id' => 28, 'quantity' => 200]); // PVC Pipes 4"
        MaterialRequestItem::create(['request_id' => $request5->id, 'material_id' => 29, 'quantity' => 150]); // PVC Pipes 2"
        MaterialRequestItem::create(['request_id' => $request5->id, 'material_id' => 32, 'quantity' => 10]); // Sanitary Fittings

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request5->id,
            'status' => 'pending',
            'created_at' => Carbon::now()->subDays(1),
        ]);

        $request6 = MaterialRequest::create([
            'project_id' => 2,
            'requested_by' => 3,
            'status' => 'pending',
            'created_at' => Carbon::now(),
        ]);

        MaterialRequestItem::create(['request_id' => $request6->id, 'material_id' => 8, 'quantity' => 2500]); // Steel 16mm
        MaterialRequestItem::create(['request_id' => $request6->id, 'material_id' => 10, 'quantity' => 200]); // Binding Wire
        MaterialRequestItem::create(['request_id' => $request6->id, 'material_id' => 3, 'quantity' => 20]); // RMC M20

        Approval::create([
            'reference_type' => 'material_request',
            'reference_id' => $request6->id,
            'status' => 'pending',
            'created_at' => Carbon::now(),
        ]);

        $this->command->info('Created 6 material requests (3 approved, 3 pending) with items and approvals');
    }
}
