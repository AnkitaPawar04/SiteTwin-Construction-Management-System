<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    use HasFactory;

    public $timestamps = false;
    protected $table = 'stock';

    protected $fillable = [
        'project_id',
        'material_id',
        'available_quantity',
    ];

    protected function casts(): array
    {
        return [
            'available_quantity' => 'integer',
            'updated_at' => 'datetime',
        ];
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function material()
    {
        return $this->belongsTo(Material::class);
    }
}
