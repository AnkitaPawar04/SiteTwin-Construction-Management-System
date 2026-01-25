<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InvoiceItem extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'invoice_id',
        'material_id',
        'task_id',
        'description',
        'quantity',
        'unit',
        'rate',
        'amount',
        'gst_percentage',
        'gst_amount',
        'total_amount',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'decimal:2',
            'rate' => 'decimal:2',
            'amount' => 'decimal:4',
            'gst_percentage' => 'decimal:2',
            'gst_amount' => 'decimal:4',
            'total_amount' => 'decimal:4',
        ];
    }

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }

    public function material()
    {
        return $this->belongsTo(Material::class);
    }

    public function task()
    {
        return $this->belongsTo(Task::class);
    }
}
