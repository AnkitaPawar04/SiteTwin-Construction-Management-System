<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Contractor extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'phone',
        'email',
        'address',
    ];

    /**
     * Get all trades for this contractor
     */
    public function trades()
    {
        return $this->hasMany(ContractorTrade::class);
    }

    /**
     * Get all ratings across all trades
     */
    public function ratings()
    {
        return $this->hasManyThrough(
            ContractorRating::class,
            ContractorTrade::class,
            'contractor_id', // Foreign key on contractor_trades table
            'trade_id',      // Foreign key on contractor_ratings table
            'id',            // Local key on contractors table
            'id'             // Local key on contractor_trades table
        );
    }

    /**
     * Get overall rating across all trades
     */
    public function getOverallRatingAttribute()
    {
        $avgSpeed = $this->ratings()->avg('speed');
        $avgQuality = $this->ratings()->avg('quality');
        
        if (!$avgSpeed || !$avgQuality) {
            return 0;
        }
        
        return round(($avgSpeed + $avgQuality) / 2, 1);
    }
}
