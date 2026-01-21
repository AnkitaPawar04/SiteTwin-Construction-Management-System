<?php

namespace App\Services;

use App\Models\Project;
use App\Models\Attendance;
use App\Models\DailyProgressReport;
use App\Models\Task;
use App\Models\Stock;
use App\Models\Invoice;
use Illuminate\Support\Facades\DB;

class DashboardService
{
    /**
     * Get dashboard data for owner
     */
    public function getOwnerDashboard($ownerId)
    {
        $projects = Project::where('owner_id', $ownerId)->get();
        $projectIds = $projects->pluck('id');

        return [
            'projects_count' => $projects->count(),
            'projects' => $projects->map(function ($project) {
                return [
                    'id' => $project->id,
                    'name' => $project->name,
                    'location' => $project->location,
                    'start_date' => $project->start_date,
                    'end_date' => $project->end_date,
                    'progress' => $this->calculateProjectProgress($project->id),
                    'time_vs_cost' => $this->getProjectTimeVsCost($project->id),
                ];
            }),
            'financial_overview' => $this->getFinancialOverview($projectIds),
            'attendance_summary' => $this->getAttendanceSummary($projectIds),
            'material_consumption' => $this->getMaterialConsumption($projectIds),
            'time_vs_cost_overall' => $this->getOverallTimeVsCost($projectIds),
        ];
    }

    private function calculateProjectProgress($projectId)
    {
        $totalTasks = Task::where('project_id', $projectId)->count();
        $completedTasks = Task::where('project_id', $projectId)
            ->where('status', Task::STATUS_COMPLETED)
            ->count();

        if ($totalTasks === 0) {
            return 0;
        }

        return round(($completedTasks / $totalTasks) * 100, 2);
    }

    private function getFinancialOverview($projectIds)
    {
        $invoices = Invoice::whereIn('project_id', $projectIds)->get();

        return [
            'total_invoices' => $invoices->count(),
            'total_amount' => $invoices->sum('total_amount'),
            'total_gst' => $invoices->sum('gst_amount'),
            'paid_amount' => $invoices->where('status', Invoice::STATUS_PAID)->sum('total_amount'),
            'pending_amount' => $invoices->where('status', Invoice::STATUS_GENERATED)->sum('total_amount'),
        ];
    }

    private function getAttendanceSummary($projectIds)
    {
        $today = now()->toDateString();
        
        return [
            'today_attendance' => Attendance::whereIn('project_id', $projectIds)
                ->where('date', $today)
                ->count(),
            'total_workers' => DB::table('project_users')
                ->whereIn('project_id', $projectIds)
                ->distinct('user_id')
                ->count(),
        ];
    }

    private function getMaterialConsumption($projectIds)
    {
        $stocks = Stock::whereIn('project_id', $projectIds)
            ->with('material')
            ->get();

        return $stocks->map(function ($stock) {
            return [
                'material' => $stock->material->name,
                'unit' => $stock->material->unit,
                'available_quantity' => $stock->available_quantity,
            ];
        });
    }

    /**
     * Get dashboard data for manager/site incharge
     */
    public function getManagerDashboard($managerId)
    {
        // Get projects where this user is assigned as manager
        $projects = DB::table('project_users')
            ->where('user_id', $managerId)
            ->join('projects', 'project_users.project_id', '=', 'projects.id')
            ->select('projects.*')
            ->get();

        $projectIds = collect($projects)->pluck('id');

        $today = now()->toDateString();
        $todayAttendance = Attendance::whereIn('project_id', $projectIds)
            ->where('date', $today)
            ->get();

        return [
            'projects_count' => count($projects),
            'projects_assigned' => collect($projects)->map(function ($project) {
                return [
                    'id' => $project->id,
                    'name' => $project->name,
                    'location' => $project->location,
                    'start_date' => $project->start_date,
                    'end_date' => $project->end_date,
                    'progress' => $this->calculateProjectProgress($project->id),
                ];
            }),
            'today_attendance' => [
                'present_count' => $todayAttendance->where('status', 'present')->count(),
                'absent_count' => $todayAttendance->where('status', 'absent')->count(),
                'total_workers' => DB::table('project_users')
                    ->whereIn('project_id', $projectIds)
                    ->distinct('user_id')
                    ->count(),
            ],
            'pending_tasks' => [
                'total' => Task::whereIn('project_id', $projectIds)
                    ->whereIn('status', ['pending', 'in_progress'])
                    ->count(),
                'by_project' => Task::whereIn('project_id', $projectIds)
                    ->whereIn('status', ['pending', 'in_progress'])
                    ->with('project')
                    ->get()
                    ->groupBy('project_id')
                    ->map(function ($tasks) {
                        return $tasks->count();
                    }),
            ],
            'pending_dprs' => DailyProgressReport::whereIn('project_id', $projectIds)
                ->where('status', 'pending')
                ->count(),
            'material_stock_summary' => $this->getMaterialConsumption($projectIds),
        ];
    }

    /**
     * Get dashboard data for worker/engineer
     */
    public function getWorkerDashboard($workerId)
    {
        // Get projects where this worker is assigned
        $projects = DB::table('project_users')
            ->where('user_id', $workerId)
            ->join('projects', 'project_users.project_id', '=', 'projects.id')
            ->select('projects.*')
            ->get();

        $projectIds = collect($projects)->pluck('id');
        $today = now()->toDateString();

        // Get today's attendance
        $todayAttendance = Attendance::where('user_id', $workerId)
            ->where('date', $today)
            ->first();

        // Get assigned tasks
        $assignedTasks = Task::whereIn('project_id', $projectIds)
            ->where('assigned_to', $workerId)
            ->get();

        // Get attendance history (last 7 days)
        $attendanceHistory = Attendance::where('user_id', $workerId)
            ->where('date', '>=', now()->subDays(7)->toDateString())
            ->orderBy('date', 'desc')
            ->get();

        return [
            'projects_count' => count($projects),
            'assigned_projects' => collect($projects)->map(function ($project) {
                return [
                    'id' => $project->id,
                    'name' => $project->name,
                    'location' => $project->location,
                ];
            }),
            'today_status' => [
                'checked_in' => $todayAttendance ? ($todayAttendance->check_in_time !== null) : false,
                'checked_out' => $todayAttendance ? ($todayAttendance->check_out_time !== null) : false,
                'status' => $todayAttendance->status ?? 'not_marked',
            ],
            'assigned_tasks' => [
                'total' => $assignedTasks->count(),
                'completed' => $assignedTasks->where('status', 'completed')->count(),
                'pending' => $assignedTasks->where('status', 'pending')->count(),
                'in_progress' => $assignedTasks->where('status', 'in_progress')->count(),
                'recent_tasks' => $assignedTasks->sortByDesc('created_at')
                    ->take(5)
                    ->map(function ($task) {
                        return [
                            'id' => $task->id,
                            'title' => $task->title,
                            'description' => $task->description,
                            'status' => $task->status,
                            'due_date' => $task->due_date,
                        ];
                    }),
            ],
            'attendance_history' => $attendanceHistory->map(function ($attendance) {
                return [
                    'date' => $attendance->date,
                    'status' => $attendance->status,
                    'check_in_time' => $attendance->check_in_time,
                    'check_out_time' => $attendance->check_out_time,
                ];
            }),
            'weekly_attendance_rate' => [
                'present' => $attendanceHistory->where('status', 'present')->count(),
                'absent' => $attendanceHistory->where('status', 'absent')->count(),
                'leave' => $attendanceHistory->where('status', 'leave')->count(),
            ],
        ];
    }

    /**
     * Calculate time vs cost for a specific project
     */
    private function getProjectTimeVsCost($projectId)
    {
        $project = Project::find($projectId);
        if (!$project) {
            return null;
        }

        // Calculate elapsed days
        $startDate = \Carbon\Carbon::parse($project->start_date);
        $endDate = $project->end_date ? \Carbon\Carbon::parse($project->end_date) : now();
        $plannedDays = $startDate->diffInDays($project->end_date ? \Carbon\Carbon::parse($project->end_date) : now());
        $elapsedDays = $startDate->diffInDays($endDate);

        // Get financial data
        $invoices = Invoice::where('project_id', $projectId)->get();
        $totalCost = $invoices->sum('total_amount');
        $paidAmount = $invoices->where('status', Invoice::STATUS_PAID)->sum('total_amount');

        // Get labor cost (from attendance records)
        $attendanceRecords = Attendance::where('project_id', $projectId)->count();
        
        // Estimate daily labor cost (can be enhanced with user wage data)
        $estimatedDailyCost = $totalCost / max($plannedDays, 1);

        return [
            'project_id' => $projectId,
            'planned_days' => $plannedDays,
            'elapsed_days' => $elapsedDays,
            'remaining_days' => max($plannedDays - $elapsedDays, 0),
            'progress_percentage' => $plannedDays > 0 ? round(($elapsedDays / $plannedDays) * 100, 2) : 0,
            'total_budget' => $totalCost,
            'spent_amount' => $paidAmount,
            'remaining_budget' => $totalCost - $paidAmount,
            'estimated_daily_cost' => round($estimatedDailyCost, 2),
            'labor_man_days' => $attendanceRecords,
        ];
    }

    /**
     * Get overall time vs cost analysis for all owner's projects
     */
    private function getOverallTimeVsCost($projectIds)
    {
        $projects = Project::whereIn('id', $projectIds)->get();
        
        $totalPlannedDays = 0;
        $totalElapsedDays = 0;
        $totalBudget = 0;
        $totalSpent = 0;

        $projectsAnalysis = [];

        foreach ($projects as $project) {
            $tvCost = $this->getProjectTimeVsCost($project->id);
            if ($tvCost) {
                $projectsAnalysis[] = $tvCost;
                $totalPlannedDays += $tvCost['planned_days'];
                $totalElapsedDays += $tvCost['elapsed_days'];
                $totalBudget += $tvCost['total_budget'];
                $totalSpent += $tvCost['spent_amount'];
            }
        }

        return [
            'total_projects' => count($projectsAnalysis),
            'total_planned_days' => $totalPlannedDays,
            'total_elapsed_days' => $totalElapsedDays,
            'overall_progress' => $totalPlannedDays > 0 ? round(($totalElapsedDays / $totalPlannedDays) * 100, 2) : 0,
            'total_budget' => $totalBudget,
            'total_spent' => $totalSpent,
            'total_remaining' => $totalBudget - $totalSpent,
            'cost_utilization_rate' => $totalBudget > 0 ? round(($totalSpent / $totalBudget) * 100, 2) : 0,
            'projects_analysis' => $projectsAnalysis,
        ];
    }

    /**
     * Get dedicated time vs cost dashboard data
     */
    public function getTimeVsCostDashboard($ownerId)
    {
        $projects = Project::where('owner_id', $ownerId)->get();
        $projectIds = $projects->pluck('id');

        return $this->getOverallTimeVsCost($projectIds);
    }
}
