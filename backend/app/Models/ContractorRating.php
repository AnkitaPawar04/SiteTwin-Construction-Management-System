<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContractorRating extends Model
{
    use HasFactory;

    protected $fillable = [
        'contractor_id',
        'project_id',
        'rating_period_start',
        'rating_period_end',
        'punctuality_score',
        'quality_score',
        'safety_score',
        'wastage_score',
        'overall_rating',
        'payment_action',
        'penalty_amount',
        'rated_by',
        'comments',
    ];

    protected function casts(): array
    {
        return [
            'rating_period_start' => 'date',
            'rating_period_end' => 'date',
            'punctuality_score' => 'decimal:1',
            'quality_score' => 'decimal:1',
            'safety_score' => 'decimal:1',
            'wastage_score' => 'decimal:1',
            'overall_rating' => 'decimal:1',
            'penalty_amount' => 'decimal:2',
        ];
    }

    // Relationships
    public function contractor()
    {
        return $this->belongsTo(User::class, 'contractor_id');
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function ratedBy()
    {
        return $this->belongsTo(User::class, 'rated_by');
    }

    // Helper methods
    public function calculateOverallRating(): float
    {
        return round(
            ($this->punctuality_score + $this->quality_score + 
             $this->safety_score + $this->wastage_score) / 4,
            1
        );
    }

    public function shouldHoldPayment(): bool
    {
        return $this->overall_rating < 5.0 || $this->payment_action === 'HOLD';
    }

    public function shouldApplyPenalty(): bool
    {
        return $this->overall_rating < 4.0 || $this->payment_action === 'PENALTY';
    }
}
