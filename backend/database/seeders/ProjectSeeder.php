<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\ProjectUser;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class ProjectSeeder extends Seeder
{
    public function run()
    {
        // Project 1: Commercial Plaza (Active)
        $project1 = Project::create([
            'name' => 'Commercial Plaza - Andheri',
            'location' => 'Andheri West, Mumbai, Maharashtra',
            'latitude' => 19.1136,
            'longitude' => 72.8697,
            'start_date' => Carbon::parse('2025-11-01'),
            'end_date' => Carbon::parse('2026-10-31'),
            'owner_id' => 1, // Rajesh Kumar
            'created_at' => Carbon::parse('2025-10-15'),
        ]);

        // Assign team to Project 1
        ProjectUser::create(['project_id' => $project1->id, 'user_id' => 2]); // Manager: Amit
        ProjectUser::create(['project_id' => $project1->id, 'user_id' => 3]); // Engineer: Vikram
        ProjectUser::create(['project_id' => $project1->id, 'user_id' => 4]); // Worker: Ramu

        // Project 2: Residential Tower (Active)
        $project2 = Project::create([
            'name' => 'Skyline Residency - Pune',
            'location' => 'Kharadi, Pune, Maharashtra',
            'latitude' => 18.5511,
            'longitude' => 73.9450,
            'start_date' => Carbon::parse('2025-12-01'),
            'end_date' => Carbon::parse('2027-11-30'),
            'owner_id' => 1,
            'created_at' => Carbon::parse('2025-11-15'),
        ]);

        // Assign team to Project 2
        ProjectUser::create(['project_id' => $project2->id, 'user_id' => 2]); // Manager: Amit
        ProjectUser::create(['project_id' => $project2->id, 'user_id' => 3]); // Engineer: Vikram
        ProjectUser::create(['project_id' => $project2->id, 'user_id' => 4]); // Worker: Ramu

        // Project 3: Villa Complex (Upcoming)
        $project3 = Project::create([
            'name' => 'Green Valley Villas - Bangalore',
            'location' => 'Whitefield, Bangalore, Karnataka',
            'latitude' => 12.9698,
            'longitude' => 77.7499,
            'start_date' => Carbon::parse('2026-03-01'),
            'end_date' => Carbon::parse('2027-02-28'),
            'owner_id' => 1,
            'created_at' => Carbon::parse('2026-01-10'),
        ]);

        // Assign team to Project 3
        ProjectUser::create(['project_id' => $project3->id, 'user_id' => 2]); // Manager: Amit
        ProjectUser::create(['project_id' => $project3->id, 'user_id' => 3]); // Engineer: Vikram
        ProjectUser::create(['project_id' => $project3->id, 'user_id' => 4]); // Worker: Ramu

        $this->command->info('Created 3 projects with team assignments');
    }
}
