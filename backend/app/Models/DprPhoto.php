<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DprPhoto extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'dpr_id',
        'photo_url',
    ];

    protected $appends = ['full_url'];

    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
        ];
    }

    public function getFullUrlAttribute()
    {
        // Generate API endpoint URL for secure photo access
        // This ensures proper authentication and authorization
        try {
            return route('api.dprs.photo', [
                'dprId' => $this->dpr_id,
                'photoId' => $this->id
            ]);
        } catch (\Exception $e) {
            // Fallback if route not found (during cache issues)
            return url('/api/dprs/' . $this->dpr_id . '/photos/' . $this->id);
        }
    }

    public function dailyProgressReport()
    {
        return $this->belongsTo(DailyProgressReport::class, 'dpr_id');
    }
}
