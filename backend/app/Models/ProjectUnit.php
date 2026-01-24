<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProjectUnit extends Model
{
    use HasFactory;

    protected $fillable = [
        'project_id',
        'unit_number',
        'unit_type',
        'floor_area',
        'floor_area_unit',
        'is_sold',
        'sold_price',
        'sold_date',
        'buyer_name',
        'allocated_cost',
        'description',
    ];

    protected $casts = [
        'floor_area' => 'decimal:2',
        'sold_price' => 'decimal:2',
        'allocated_cost' => 'decimal:2',
        'is_sold' => 'boolean',
        'sold_date' => 'date',
    ];

    /**
     * Get the project that owns the unit.
     */
    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    /**
     * Calculate profit/loss for sold unit.
     */
    public function getProfitLoss(): ?float
    {
        if (!$this->is_sold || !$this->sold_price || !$this->allocated_cost) {
            return null;
        }
        
        return $this->sold_price - $this->allocated_cost;
    }

    /**
     * Calculate profit margin percentage.
     */
    public function getProfitMargin(): ?float
    {
        if (!$this->is_sold || !$this->sold_price || !$this->allocated_cost) {
            return null;
        }
        
        return (($this->sold_price - $this->allocated_cost) / $this->sold_price) * 100;
    }

    /**
     * Scope to get only sold units.
     */
    public function scopeSold($query)
    {
        return $query->where('is_sold', true);
    }

    /**
     * Scope to get only unsold units.
     */
    public function scopeUnsold($query)
    {
        return $query->where('is_sold', false);
    }
}
