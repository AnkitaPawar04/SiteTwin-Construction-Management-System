<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DailyProgressReport extends Model
{
    use HasFactory;

    const STATUS_SUBMITTED = 'submitted';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';

    public $timestamps = false;

    protected $fillable = [
        'project_id',
        'user_id',
        'work_description',
        'report_date',
        'latitude',
        'longitude',
        'status',
        'billing_amount',
        'gst_percentage',
    ];

    protected function casts(): array
    {
        return [
            'report_date' => 'date',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'created_at' => 'datetime',
        ];
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function photos()
    {
        return $this->hasMany(DprPhoto::class, 'dpr_id');
    }

    public function approval()
    {
        return $this->morphOne(Approval::class, 'reference');
    }
}
