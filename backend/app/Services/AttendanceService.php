<?php

namespace App\Services;

use App\Models\Attendance;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AttendanceService
{
    public function checkIn($userId, $projectId, $latitude, $longitude)
    {
        $today = Carbon::today()->toDateString();
        
        // Check if already checked in today
        $existingAttendance = Attendance::where('user_id', $userId)
            ->where('project_id', $projectId)
            ->where('date', $today)
            ->first();

        if ($existingAttendance) {
            throw new \Exception('Attendance already marked for today');
        }

        // Validate location (simplified - you can add more complex validation)
        // In production, check if coordinates are within project boundaries

        $attendance = Attendance::create([
            'user_id' => $userId,
            'project_id' => $projectId,
            'date' => $today,
            'check_in' => now(),
            'latitude' => $latitude,
            'longitude' => $longitude,
            'is_verified' => true, // Auto-verify or add manual verification
        ]);

        return $attendance;
    }

    public function checkOut($attendanceId, $latitude, $longitude)
    {
        $attendance = Attendance::findOrFail($attendanceId);

        if ($attendance->check_out) {
            throw new \Exception('Already checked out');
        }

        $attendance->update([
            'check_out' => now(),
        ]);

        return $attendance;
    }

    public function getAttendanceByProject($projectId, $startDate = null, $endDate = null)
    {
        $query = Attendance::where('project_id', $projectId)
            ->with('user');

        if ($startDate) {
            $query->where('date', '>=', $startDate);
        }

        if ($endDate) {
            $query->where('date', '<=', $endDate);
        }

        return $query->orderBy('date', 'desc')->get();
    }

    /**
     * Get all attendance records (for owners)
     */
    public function getAllAttendance($startDate = null, $endDate = null)
    {
        $query = Attendance::with('user');

        if ($startDate) {
            $query->where('date', '>=', $startDate);
        }

        if ($endDate) {
            $query->where('date', '<=', $endDate);
        }

        return $query->orderBy('date', 'desc')->get();
    }

    public function getUserAttendance($userId, $projectId = null)
    {
        $query = Attendance::where('user_id', $userId)
            ->with('user');

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        return $query->orderBy('date', 'desc')->get();
    }

    /**
     * Get team attendance summary for a specific date
     */
    public function getTeamAttendanceSummary($projectId, $date = null)
    {
        $date = $date ?? now()->toDateString();

        // Get all users assigned to this project
        $projectUsers = DB::table('project_users')
            ->where('project_id', $projectId)
            ->join('users', 'project_users.user_id', '=', 'users.id')
            ->select('users.id', 'users.name', 'users.email', 'users.role')
            ->get();

        // Get attendance for all users on this date
        $attendances = Attendance::where('project_id', $projectId)
            ->where('date', $date)
            ->with('user')
            ->get()
            ->keyBy('user_id');

        $summary = [
            'date' => $date,
            'total_workers' => $projectUsers->count(),
            'present' => 0,
            'absent' => 0,
            'leave' => 0,
            'not_marked' => 0,
            'attendance_rate' => 0,
            'workers' => [],
        ];

        foreach ($projectUsers as $user) {
            $attendance = $attendances->get($user->id);

            $workerStatus = [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
            ];

            if ($attendance) {
                $workerStatus['status'] = $attendance->status ?? 'present';
                $workerStatus['check_in_time'] = $attendance->check_in_time;
                $workerStatus['check_out_time'] = $attendance->check_out_time;

                if ($attendance->status === 'present' || $attendance->check_in_time) {
                    $summary['present']++;
                } elseif ($attendance->status === 'leave') {
                    $summary['leave']++;
                } else {
                    $summary['absent']++;
                }
            } else {
                $workerStatus['status'] = 'not_marked';
                $summary['not_marked']++;
            }

            $summary['workers'][] = $workerStatus;
        }

        // Calculate attendance rate
        if ($summary['total_workers'] > 0) {
            $summary['attendance_rate'] = round(
                (($summary['present'] + $summary['leave']) / $summary['total_workers']) * 100,
                2
            );
        }

        return $summary;
    }

    /**
     * Get attendance trends for a period
     */
    public function getAttendanceTrends($projectId, $days = 30)
    {
        $startDate = now()->subDays($days)->toDateString();
        $endDate = now()->toDateString();

        $projectUsers = DB::table('project_users')
            ->where('project_id', $projectId)
            ->distinct('user_id')
            ->count('user_id');

        $dailyData = Attendance::where('project_id', $projectId)
            ->whereBetween('date', [$startDate, $endDate])
            ->selectRaw('date, COUNT(*) as total, SUM(CASE WHEN status = "present" OR check_in_time IS NOT NULL THEN 1 ELSE 0 END) as present')
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->get();

        $trends = [];
        foreach ($dailyData as $day) {
            $rate = $projectUsers > 0 ? round(($day->present / $projectUsers) * 100, 2) : 0;
            $trends[] = [
                'date' => $day->date,
                'total_present' => $day->present,
                'attendance_rate' => $rate,
            ];
        }

        return [
            'period_days' => $days,
            'total_project_workers' => $projectUsers,
            'daily_trends' => $trends,
        ];
    }
}
