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

    public function getUserAttendance($userId, $projectId = null)
    {
        $query = Attendance::where('user_id', $userId);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        return $query->orderBy('date', 'desc')->get();
    }
}
