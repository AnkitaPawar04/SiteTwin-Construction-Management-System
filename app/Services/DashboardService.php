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
                ];
            }),
            'financial_overview' => $this->getFinancialOverview($projectIds),
            'attendance_summary' => $this->getAttendanceSummary($projectIds),
            'material_consumption' => $this->getMaterialConsumption($projectIds),
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
}
