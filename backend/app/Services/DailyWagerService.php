<?php

namespace App\Services;

use App\Models\DailyWagerAttendance;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;

class DailyWagerService
{
    /**
     * Record check-in with face recognition
     */
    public function checkIn(array $data): DailyWagerAttendance
    {
        // Handle face image upload
        $faceImagePath = null;
        if (isset($data['face_image'])) {
            $faceImagePath = $data['face_image']->store('wager-faces', 'public');
        }

        return DailyWagerAttendance::create([
            'wager_name' => $data['wager_name'],
            'wager_phone' => $data['wager_phone'] ?? null,
            'project_id' => $data['project_id'],
            'attendance_date' => $data['attendance_date'] ?? Carbon::today(),
            'check_in_time' => Carbon::now(),
            'face_image_path' => $faceImagePath,
            'face_encoding' => $data['face_encoding'] ?? null,
            'wage_rate_per_hour' => $data['wage_rate_per_hour'],
            'status' => 'PENDING',
        ]);
    }

    /**
     * Record check-out and calculate wage
     */
    public function checkOut(int $attendanceId): DailyWagerAttendance
    {
        $attendance = DailyWagerAttendance::findOrFail($attendanceId);

        if ($attendance->check_out_time) {
            throw new \Exception('Already checked out');
        }

        $checkOutTime = Carbon::now();
        $checkInTime = Carbon::parse($attendance->check_in_time);
        $hoursWorked = round($checkOutTime->diffInMinutes($checkInTime) / 60, 2);

        $totalWage = round($hoursWorked * $attendance->wage_rate_per_hour, 2);

        $attendance->update([
            'check_out_time' => $checkOutTime,
            'hours_worked' => $hoursWorked,
            'total_wage' => $totalWage,
        ]);

        return $attendance->fresh();
    }

    /**
     * Verify attendance record
     */
    public function verifyAttendance(int $attendanceId, int $verifiedBy): DailyWagerAttendance
    {
        $attendance = DailyWagerAttendance::findOrFail($attendanceId);

        $attendance->update([
            'verified_by' => $verifiedBy,
            'verified_at' => Carbon::now(),
            'status' => 'VERIFIED',
        ]);

        return $attendance->fresh();
    }

    /**
     * Reject attendance record
     */
    public function rejectAttendance(int $attendanceId, int $verifiedBy): DailyWagerAttendance
    {
        $attendance = DailyWagerAttendance::findOrFail($attendanceId);

        $attendance->update([
            'verified_by' => $verifiedBy,
            'verified_at' => Carbon::now(),
            'status' => 'REJECTED',
        ]);

        return $attendance->fresh();
    }

    /**
     * Get daily attendance report
     */
    public function getDailyReport(int $projectId, ?string $date = null): array
    {
        $date = $date ?? Carbon::today()->toDateString();

        $attendances = DailyWagerAttendance::where('project_id', $projectId)
            ->where('attendance_date', $date)
            ->with(['project', 'verifiedBy'])
            ->get();

        return [
            'date' => $date,
            'total_wagers' => $attendances->count(),
            'verified_count' => $attendances->where('status', 'VERIFIED')->count(),
            'pending_count' => $attendances->where('status', 'PENDING')->count(),
            'total_hours' => $attendances->sum('hours_worked'),
            'total_wages' => $attendances->sum('total_wage'),
            'attendances' => $attendances,
        ];
    }

    /**
     * Get wage summary for period
     */
    public function getWageSummary(int $projectId, string $startDate, string $endDate): array
    {
        $attendances = DailyWagerAttendance::where('project_id', $projectId)
            ->whereBetween('attendance_date', [$startDate, $endDate])
            ->where('status', 'VERIFIED')
            ->get();

        $wagerSummary = $attendances->groupBy('wager_name')->map(function ($group) {
            return [
                'wager_name' => $group->first()->wager_name,
                'wager_phone' => $group->first()->wager_phone,
                'total_days' => $group->count(),
                'total_hours' => $group->sum('hours_worked'),
                'total_wage' => $group->sum('total_wage'),
                'avg_hours_per_day' => round($group->avg('hours_worked'), 2),
            ];
        })->values();

        return [
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'total_unique_wagers' => $wagerSummary->count(),
            'total_wage_amount' => $attendances->sum('total_wage'),
            'total_work_days' => $attendances->count(),
            'wager_summary' => $wagerSummary,
        ];
    }

    /**
     * Match face encoding (placeholder for ML integration)
     */
    public function matchFaceEncoding(string $newEncoding, int $projectId): ?array
    {
        // This would integrate with a face recognition service
        // For now, return null (manual verification required)
        
        // Future implementation would:
        // 1. Query existing face encodings for the project
        // 2. Use ML model to compare encodings
        // 3. Return matched wager if confidence > threshold
        
        return null;
    }
}
