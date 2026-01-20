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

    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
        ];
    }

    public function dailyProgressReport()
    {
        return $this->belongsTo(DailyProgressReport::class, 'dpr_id');
    }
}
