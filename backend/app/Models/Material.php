<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'name',
        'unit',
        'gst_percentage',
    ];

    protected function casts(): array
    {
        return [
            'gst_percentage' => 'decimal:2',
        ];
    }

    public function materialRequestItems()
    {
        return $this->hasMany(MaterialRequestItem::class);
    }

    public function stock()
    {
        return $this->hasMany(Stock::class);
    }

    public function stockTransactions()
    {
        return $this->hasMany(StockTransaction::class);
    }
}
