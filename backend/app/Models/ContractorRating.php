<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContractorRating extends Model
{
    use HasFactory;

    protected $fillable = [
        'contractor_id',
        'trade_id',
        'project_id',
        'speed',
        'quality',
        'rated_by',
        'comments',
    ];

    protected function casts(): array
    {
        return [
            'speed' => 'decimal:1',
            'quality' => 'decimal:1',
        ];
    }

    // Relationships
    public function contractor()
    {
        return $this->belongsTo(Contractor::class);
    }

    public function trade()
    {
        return $this->belongsTo(ContractorTrade::class, 'trade_id');
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function ratedBy()
    {
        return $this->belongsTo(User::class, 'rated_by');
    }

    /**
     * Calculate trade rating: (speed + quality) / 2
     */
    public function getTradeRatingAttribute(): float
    {
        return round(($this->speed + $this->quality) / 2, 1);
    }
}
