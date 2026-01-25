<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContractorTrade extends Model
{
    use HasFactory;

    protected $fillable = [
        'contractor_id',
        'trade_type',
    ];

    /**
     * Get the contractor that owns this trade
     */
    public function contractor()
    {
        return $this->belongsTo(Contractor::class);
    }

    /**
     * Get all ratings for this trade
     */
    public function ratings()
    {
        return $this->hasMany(ContractorRating::class, 'trade_id');
    }

    /**
     * Get average rating for this trade
     */
    public function getAverageRatingAttribute()
    {
        $avgSpeed = $this->ratings()->avg('speed');
        $avgQuality = $this->ratings()->avg('quality');
        
        if (!$avgSpeed || !$avgQuality) {
            return 0;
        }
        
        return round(($avgSpeed + $avgQuality) / 2, 1);
    }
}
