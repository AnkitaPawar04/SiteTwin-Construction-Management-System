<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DailyWagerAttendance extends Model
{
    use HasFactory;

    protected $table = 'daily_wager_attendance';

    protected $fillable = [
        'wager_name',
        'wager_phone',
        'project_id',
        'attendance_date',
        'check_in_time',
        'check_out_time',
        'face_image_path',
        'face_encoding',
        'hours_worked',
        'wage_rate_per_hour',
        'total_wage',
        'verified_by',
        'verified_at',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'attendance_date' => 'date',
            'check_in_time' => 'datetime',
            'check_out_time' => 'datetime',
            'hours_worked' => 'decimal:2',
            'wage_rate_per_hour' => 'decimal:2',
            'total_wage' => 'decimal:2',
            'verified_at' => 'datetime',
        ];
    }

    // Relationships
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    // Helper methods
    public function calculateHoursWorked(): float
    {
        if (!$this->check_in_time || !$this->check_out_time) {
            return 0;
        }

        $checkIn = \Carbon\Carbon::parse($this->check_in_time);
        $checkOut = \Carbon\Carbon::parse($this->check_out_time);
        
        return round($checkOut->diffInMinutes($checkIn) / 60, 2);
    }

    public function calculateTotalWage(): float
    {
        return round($this->hours_worked * $this->wage_rate_per_hour, 2);
    }

    public function isVerified(): bool
    {
        return $this->status === 'VERIFIED';
    }
}
