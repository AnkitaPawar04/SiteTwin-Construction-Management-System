<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MaterialRequestItem extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'request_id',
        'material_id',
        'quantity',
    ];

    protected $appends = [
        'material_name',
        'unit',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'integer',
        ];
    }

    public function getMaterialNameAttribute()
    {
        return $this->material?->name;
    }

    public function getUnitAttribute()
    {
        return $this->material?->unit;
    }

    public function materialRequest()
    {
        return $this->belongsTo(MaterialRequest::class, 'request_id');
    }

    public function material()
    {
        return $this->belongsTo(Material::class);
    }
}
