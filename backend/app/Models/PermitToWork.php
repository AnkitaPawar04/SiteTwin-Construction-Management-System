<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class PermitToWork extends Model
{
    use HasFactory;

    protected $table = 'permit_to_work';

    const TASK_HEIGHT = 'HEIGHT';
    const TASK_ELECTRICAL = 'ELECTRICAL';
    const TASK_WELDING = 'WELDING';
    const TASK_CONFINED_SPACE = 'CONFINED_SPACE';
    const TASK_HOT_WORK = 'HOT_WORK';
    const TASK_EXCAVATION = 'EXCAVATION';

    const STATUS_PENDING = 'PENDING';
    const STATUS_APPROVED = 'APPROVED';
    const STATUS_IN_PROGRESS = 'IN_PROGRESS';
    const STATUS_COMPLETED = 'COMPLETED';
    const STATUS_REJECTED = 'REJECTED';

    const FIXED_OTP = '123456'; // MVP fixed OTP

    protected $fillable = [
        'project_id',
        'task_type',
        'description',
        'safety_measures',
        'supervisor_id',
        'requested_at',
        'approved_by',
        'otp_code',
        'approved_at',
        'started_at',
        'completed_at',
        'status',
        'notes',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'requested_at' => 'datetime',
            'approved_at' => 'datetime',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    // Relationships
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function supervisor()
    {
        return $this->belongsTo(User::class, 'supervisor_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    // Helper methods
    public function verifyOTP(string $otp): bool
    {
        return $this->otp_code === $otp;
    }

    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function isApproved(): bool
    {
        return $this->status === self::STATUS_APPROVED;
    }

    public function isInProgress(): bool
    {
        return $this->status === self::STATUS_IN_PROGRESS;
    }

    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    public function canStartWork(): bool
    {
        return $this->status === self::STATUS_APPROVED;
    }

    public function isExpired(): bool
    {
        return false; // No expiry for fixed OTP
    }
}
