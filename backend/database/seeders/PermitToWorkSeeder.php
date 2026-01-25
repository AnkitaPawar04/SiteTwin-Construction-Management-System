<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PermitToWork;
use App\Models\User;
use App\Models\Project;
use Carbon\Carbon;

class PermitToWorkSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get users
        $supervisor = User::where('role', 'supervisor')->first();
        $safetyOfficer = User::where('role', 'safety_officer')->first();
        
        // Get any projects
        $projects = Project::all();

        if (!$supervisor || !$safetyOfficer || $projects->count() < 1) {
            $this->command->warn('Users or projects not found. Run UserSeeder and ProjectSeeder first.');
            return;
        }

        // Use first 3 projects or all available
        $project1 = $projects->get(0);
        $project2 = $projects->count() > 1 ? $projects->get(1) : $project1;
        $project3 = $projects->count() > 2 ? $projects->get(2) : $project1;

        // Create sample permits with different statuses and task types

        // 1. PENDING - Height Work
        PermitToWork::create([
            'project_id' => $project1->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_HEIGHT,
            'description' => 'Installation of steel beams at 15m height for metro platform',
            'safety_measures' => 'Safety harness, safety net, toe boards, proper scaffolding, buddy system',
            'status' => PermitToWork::STATUS_PENDING,
            'requested_at' => Carbon::now()->subHours(2),
        ]);

        // 2. APPROVED - Electrical Work
        PermitToWork::create([
            'project_id' => $project1->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_ELECTRICAL,
            'description' => 'High voltage cable installation for metro power supply (11kV)',
            'safety_measures' => 'Insulated gloves, safety boots, lockout/tagout procedure, voltage tester, fire extinguisher',
            'status' => PermitToWork::STATUS_APPROVED,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subHours(4),
            'approved_at' => Carbon::now()->subHours(1),
            'otp_code' => PermitToWork::FIXED_OTP,
        ]);

        // 3. IN_PROGRESS - Welding Work
        PermitToWork::create([
            'project_id' => $project2->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_WELDING,
            'description' => 'Welding of structural steel columns for residential building foundation',
            'safety_measures' => 'Welding helmet, fire blanket, ventilation, fire watch, spark shields',
            'status' => PermitToWork::STATUS_IN_PROGRESS,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subDays(1)->subHours(6),
            'approved_at' => Carbon::now()->subDays(1)->subHours(3),
            'started_at' => Carbon::now()->subDays(1),
            'otp_code' => PermitToWork::FIXED_OTP,
        ]);

        // 4. COMPLETED - Confined Space
        PermitToWork::create([
            'project_id' => $project2->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_CONFINED_SPACE,
            'description' => 'Underground drainage inspection and repair work',
            'safety_measures' => 'Gas detector, ventilation blower, rescue tripod, safety harness, communication radio',
            'status' => PermitToWork::STATUS_COMPLETED,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subDays(3),
            'approved_at' => Carbon::now()->subDays(3)->addHours(1),
            'started_at' => Carbon::now()->subDays(3)->addHours(2),
            'completed_at' => Carbon::now()->subDays(2),
            'otp_code' => PermitToWork::FIXED_OTP,
        ]);

        // 5. REJECTED - Hot Work
        PermitToWork::create([
            'project_id' => $project3->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_HOT_WORK,
            'description' => 'Cutting and grinding metal ducts near fuel storage area',
            'safety_measures' => 'Fire extinguisher, fire blanket, spark shields',
            'status' => PermitToWork::STATUS_REJECTED,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subDays(2),
            'rejection_reason' => 'Insufficient safety measures for hot work near fuel storage. Please add: fuel removal/relocation, gas monitoring, fire watch personnel, and obtain additional fire department approval.',
        ]);

        // 6. PENDING - Excavation Work
        PermitToWork::create([
            'project_id' => $project3->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_EXCAVATION,
            'description' => 'Deep excavation (4m depth) for shopping mall foundation',
            'safety_measures' => 'Shoring/shielding system, ladder access, soil testing, utility location, barrier fencing',
            'status' => PermitToWork::STATUS_PENDING,
            'requested_at' => Carbon::now()->subMinutes(30),
        ]);

        // 7. COMPLETED - Height Work
        PermitToWork::create([
            'project_id' => $project1->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_HEIGHT,
            'description' => 'Painting work on metro station roof at 12m height',
            'safety_measures' => 'Full body harness, double lanyard, safety line, edge protection, toolbox talk',
            'status' => PermitToWork::STATUS_COMPLETED,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subDays(5),
            'approved_at' => Carbon::now()->subDays(5)->addHours(1),
            'started_at' => Carbon::now()->subDays(5)->addHours(2),
            'completed_at' => Carbon::now()->subDays(4),
            'otp_code' => PermitToWork::FIXED_OTP,
        ]);

        // 8. IN_PROGRESS - Electrical Work
        PermitToWork::create([
            'project_id' => $project3->id,
            'supervisor_id' => $supervisor->id,
            'task_type' => PermitToWork::TASK_ELECTRICAL,
            'description' => 'Installation of main distribution panel for shopping mall',
            'safety_measures' => 'Insulated tools, rubber mats, lockout/tagout, voltage tester, arc flash PPE',
            'status' => PermitToWork::STATUS_IN_PROGRESS,
            'approved_by' => $safetyOfficer->id,
            'requested_at' => Carbon::now()->subHours(8),
            'approved_at' => Carbon::now()->subHours(5),
            'started_at' => Carbon::now()->subHours(3),
            'otp_code' => PermitToWork::FIXED_OTP,
        ]);

        $this->command->info('Created 8 sample permits:');
        $this->command->info('- 2 PENDING (Height Work, Excavation)');
        $this->command->info('- 1 APPROVED (Electrical - waiting for OTP verification)');
        $this->command->info('- 2 IN_PROGRESS (Welding, Electrical)');
        $this->command->info('- 2 COMPLETED (Confined Space, Height Work)');
        $this->command->info('- 1 REJECTED (Hot Work - insufficient safety measures)');
    }
}
