<?php

namespace App\Services;

use App\Models\PermitToWork;
use Carbon\Carbon;

class PermitService
{
    /**
     * Request new permit
     */
    public function requestPermit(array $data): PermitToWork
    {
        return PermitToWork::create([
            'project_id' => $data['project_id'],
            'task_description' => $data['task_description'],
            'risk_level' => $data['risk_level'],
            'requested_by' => $data['requested_by'],
            'requested_at' => Carbon::now(),
            'safety_officer_id' => $data['safety_officer_id'] ?? null,
            'safety_measures' => $data['safety_measures'] ?? null,
            'status' => 'PENDING',
        ]);
    }

    /**
     * Generate and send OTP to safety officer
     */
    public function generateOTP(int $permitId): array
    {
        $permit = PermitToWork::findOrFail($permitId);

        if ($permit->status !== 'PENDING') {
            throw new \Exception("Permit is not in PENDING status. Current status: {$permit->status}");
        }

        $otp = $permit->generateOTP();

        // TODO: Send OTP via SMS/Email to safety officer
        // For now, return in response (development only)

        return [
            'permit_id' => $permit->id,
            'otp_code' => $otp, // Remove in production
            'otp_expires_at' => $permit->otp_expires_at,
            'message' => 'OTP sent to safety officer',
        ];
    }

    /**
     * Verify OTP and approve permit
     */
    public function verifyOTP(int $permitId, string $otp): PermitToWork
    {
        $permit = PermitToWork::findOrFail($permitId);

        if (!$permit->verifyOTP($otp)) {
            throw new \Exception('Invalid or expired OTP');
        }

        return $permit->fresh();
    }

    /**
     * Reject permit
     */
    public function rejectPermit(int $permitId, string $reason): PermitToWork
    {
        $permit = PermitToWork::findOrFail($permitId);

        $permit->update([
            'status' => 'REJECTED',
            'rejection_reason' => $reason,
        ]);

        return $permit->fresh();
    }

    /**
     * Start work
     */
    public function startWork(int $permitId): PermitToWork
    {
        $permit = PermitToWork::findOrFail($permitId);

        if ($permit->status !== 'APPROVED') {
            throw new \Exception("Permit must be approved before starting work. Current status: {$permit->status}");
        }

        $permit->update([
            'work_started_at' => Carbon::now(),
            'status' => 'IN_PROGRESS',
        ]);

        return $permit->fresh();
    }

    /**
     * Complete work
     */
    public function completeWork(int $permitId, int $completedBy, ?string $notes = null): PermitToWork
    {
        $permit = PermitToWork::findOrFail($permitId);

        if ($permit->status !== 'IN_PROGRESS') {
            throw new \Exception("Permit must be in progress to complete. Current status: {$permit->status}");
        }

        $permit->update([
            'work_completed_at' => Carbon::now(),
            'completed_by' => $completedBy,
            'completion_notes' => $notes,
            'status' => 'COMPLETED',
        ]);

        return $permit->fresh();
    }

    /**
     * Get active permits for project
     */
    public function getActivePermits(int $projectId): array
    {
        $permits = PermitToWork::where('project_id', $projectId)
            ->whereIn('status', ['PENDING', 'OTP_SENT', 'APPROVED', 'IN_PROGRESS'])
            ->with(['requestedBy', 'safetyOfficer'])
            ->orderBy('requested_at', 'desc')
            ->get();

        return [
            'total_active' => $permits->count(),
            'pending' => $permits->where('status', 'PENDING')->count(),
            'approved' => $permits->where('status', 'APPROVED')->count(),
            'in_progress' => $permits->where('status', 'IN_PROGRESS')->count(),
            'permits' => $permits,
        ];
    }

    /**
     * Get critical risk permits
     */
    public function getCriticalRiskPermits(?int $projectId = null): array
    {
        $query = PermitToWork::whereIn('risk_level', ['HIGH', 'CRITICAL'])
            ->whereIn('status', ['PENDING', 'OTP_SENT', 'APPROVED', 'IN_PROGRESS'])
            ->with(['requestedBy', 'safetyOfficer', 'project']);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        return $query->orderBy('requested_at', 'desc')->get()->toArray();
    }

    /**
     * Get permit statistics
     */
    public function getPermitStatistics(int $projectId, ?string $startDate = null, ?string $endDate = null): array
    {
        $query = PermitToWork::where('project_id', $projectId);

        if ($startDate && $endDate) {
            $query->whereBetween('requested_at', [$startDate, $endDate]);
        }

        $permits = $query->get();

        return [
            'total_permits' => $permits->count(),
            'approved' => $permits->where('status', 'APPROVED')->count(),
            'rejected' => $permits->where('status', 'REJECTED')->count(),
            'completed' => $permits->where('status', 'COMPLETED')->count(),
            'by_risk_level' => [
                'low' => $permits->where('risk_level', 'LOW')->count(),
                'medium' => $permits->where('risk_level', 'MEDIUM')->count(),
                'high' => $permits->where('risk_level', 'HIGH')->count(),
                'critical' => $permits->where('risk_level', 'CRITICAL')->count(),
            ],
            'avg_approval_time_minutes' => $this->calculateAverageApprovalTime($permits),
        ];
    }

    /**
     * Calculate average approval time
     */
    private function calculateAverageApprovalTime($permits): ?float
    {
        $approvedPermits = $permits->filter(function ($permit) {
            return $permit->approved_at && $permit->requested_at;
        });

        if ($approvedPermits->isEmpty()) {
            return null;
        }

        $totalMinutes = $approvedPermits->sum(function ($permit) {
            return Carbon::parse($permit->requested_at)->diffInMinutes($permit->approved_at);
        });

        return round($totalMinutes / $approvedPermits->count(), 2);
    }
}
