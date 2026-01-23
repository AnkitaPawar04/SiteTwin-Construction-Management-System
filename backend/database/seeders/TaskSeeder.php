<?php

namespace Database\Seeders;

use App\Models\Task;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    public function run()
    {
        $tasks = [
            // Project 1 Tasks
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Foundation excavation - Block A',
                'description' => 'Complete excavation work for Block A foundation. Depth: 12 feet.',
                'status' => 'completed',
                'created_at' => Carbon::now()->subDays(8),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Steel reinforcement - Ground floor columns',
                'description' => 'Install steel bars for all ground floor columns as per structural drawings.',
                'status' => 'completed',
                'created_at' => Carbon::now()->subDays(7),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 2,
                'title' => 'Concrete pouring - Ground floor slab',
                'description' => 'Pour M25 grade concrete for ground floor slab. Area: 500 sq ft.',
                'status' => 'in_progress',
                'created_at' => Carbon::now()->subDays(5),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 2,
                'title' => 'Brickwork - External walls',
                'description' => 'Complete external wall brickwork for ground floor using red clay bricks.',
                'status' => 'in_progress',
                'created_at' => Carbon::now()->subDays(4),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Electrical conduit installation - First floor',
                'description' => 'Install electrical conduits for first floor as per electrical layout.',
                'status' => 'pending',
                'created_at' => Carbon::now()->subDays(2),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 2,
                'title' => 'Plumbing rough-in - Ground floor',
                'description' => 'Complete plumbing rough-in work for ground floor bathrooms and kitchen.',
                'status' => 'pending',
                'created_at' => Carbon::now()->subDays(1),
            ],
            [
                'project_id' => 1,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Plastering - Interior walls',
                'description' => 'Apply cement plaster on interior walls. Mix ratio: 1:4.',
                'status' => 'pending',
                'created_at' => Carbon::now(),
            ],

            // Project 2 Tasks
            [
                'project_id' => 2,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Site preparation and leveling',
                'description' => 'Clear the site and level the ground for construction.',
                'status' => 'completed',
                'created_at' => Carbon::now()->subDays(6),
            ],
            [
                'project_id' => 2,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Foundation marking and layout',
                'description' => 'Mark foundation layout as per approved plan.',
                'status' => 'completed',
                'created_at' => Carbon::now()->subDays(5),
            ],
            [
                'project_id' => 2,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Foundation excavation - Phase 1',
                'description' => 'Excavate foundation for Tower A. Depth: 15 feet.',
                'status' => 'in_progress',
                'created_at' => Carbon::now()->subDays(3),
            ],
            [
                'project_id' => 2,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'PCC laying - Foundation base',
                'description' => 'Lay Plain Cement Concrete (PCC) for foundation base.',
                'status' => 'pending',
                'created_at' => Carbon::now()->subDays(1),
            ],
            [
                'project_id' => 2,
                'assigned_to' => 4,
                'assigned_by' => 3,
                'title' => 'Steel fixing - Foundation raft',
                'description' => 'Fix steel reinforcement for raft foundation.',
                'status' => 'pending',
                'created_at' => Carbon::now(),
            ],
        ];

        foreach ($tasks as $task) {
            Task::create($task);
        }

        $this->command->info('Created ' . count($tasks) . ' tasks');
    }
}
