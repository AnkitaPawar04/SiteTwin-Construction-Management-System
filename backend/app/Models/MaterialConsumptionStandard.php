<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MaterialConsumptionStandard extends Model
{
    use HasFactory;

    protected $fillable = [
        'project_id',
        'material_id',
        'standard_quantity',
        'unit',
        'variance_tolerance_percentage',
        'description',
    ];

    protected $casts = [
        'standard_quantity' => 'decimal:2',
        'variance_tolerance_percentage' => 'decimal:2',
    ];

    /**
     * Get the project that owns the consumption standard.
     */
    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    /**
     * Get the material that owns the consumption standard.
     */
    public function material(): BelongsTo
    {
        return $this->belongsTo(Material::class);
    }

    /**
     * Calculate maximum allowed consumption (with tolerance).
     */
    public function getMaxAllowedConsumption(): float
    {
        return $this->standard_quantity * (1 + ($this->variance_tolerance_percentage / 100));
    }

    /**
     * Calculate minimum expected consumption (with tolerance).
     */
    public function getMinExpectedConsumption(): float
    {
        return $this->standard_quantity * (1 - ($this->variance_tolerance_percentage / 100));
    }
}
