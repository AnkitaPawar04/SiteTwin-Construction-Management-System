<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class PermitToWork extends Model
{
    use HasFactory;

    protected $table = 'permit_to_work';

    protected $fillable = [
        'project_id',
        'task_description',
        'risk_level',
        'requested_by',
        'requested_at',
        'safety_officer_id',
        'otp_code',
        'otp_generated_at',
        'otp_expires_at',
        'approved_at',
        'work_started_at',
        'work_completed_at',
        'completed_by',
        'status',
        'safety_measures',
        'rejection_reason',
        'completion_notes',
    ];

    protected function casts(): array
    {
        return [
            'requested_at' => 'datetime',
            'otp_generated_at' => 'datetime',
            'otp_expires_at' => 'datetime',
            'approved_at' => 'datetime',
            'work_started_at' => 'datetime',
            'work_completed_at' => 'datetime',
        ];
    }

    // Relationships
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function requestedBy()
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function safetyOfficer()
    {
        return $this->belongsTo(User::class, 'safety_officer_id');
    }

    public function completedBy()
    {
        return $this->belongsTo(User::class, 'completed_by');
    }

    // Helper methods
    public function generateOTP(): string
    {
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        
        $this->update([
            'otp_code' => $otp,
            'otp_generated_at' => Carbon::now(),
            'otp_expires_at' => Carbon::now()->addMinutes(15),
            'status' => 'OTP_SENT',
        ]);

        return $otp;
    }

    public function verifyOTP(string $otp): bool
    {
        if ($this->otp_code !== $otp) {
            return false;
        }

        if (Carbon::now()->isAfter($this->otp_expires_at)) {
            $this->update(['status' => 'EXPIRED']);
            return false;
        }

        $this->update([
            'approved_at' => Carbon::now(),
            'status' => 'APPROVED',
        ]);

        return true;
    }

    public function isExpired(): bool
    {
        return $this->otp_expires_at && Carbon::now()->isAfter($this->otp_expires_at);
    }

    public function isApproved(): bool
    {
        return $this->status === 'APPROVED';
    }

    public function isCriticalRisk(): bool
    {
        return in_array($this->risk_level, ['HIGH', 'CRITICAL']);
    }
}
