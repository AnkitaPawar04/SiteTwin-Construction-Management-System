<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    use HasFactory;

    const GST_TYPE_GST = 'gst';
    const GST_TYPE_NON_GST = 'non_gst';

    public $timestamps = false;

    protected $fillable = [
        'name',
        'unit',
        'gst_type',
        'gst_percentage',
    ];

    protected function casts(): array
    {
        return [
            'gst_percentage' => 'decimal:2',
        ];
    }

    // Helper methods
    public function isGstApplicable()
    {
        return $this->gst_type === self::GST_TYPE_GST;
    }

    public function isNonGst()
    {
        return $this->gst_type === self::GST_TYPE_NON_GST;
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
