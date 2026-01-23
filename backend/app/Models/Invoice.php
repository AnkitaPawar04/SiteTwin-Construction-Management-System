<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    const STATUS_GENERATED = 'generated';
    const STATUS_PAID = 'paid';

    public $timestamps = false;

    protected $fillable = [
        'project_id',
        'task_id',
        'dpr_id',
        'invoice_number',
        'total_amount',
        'gst_amount',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'total_amount' => 'decimal:4',
            'gst_amount' => 'decimal:4',
            'created_at' => 'datetime',
        ];
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function items()
    {
        return $this->hasMany(InvoiceItem::class);
    }

    public function task()
    {
        return $this->belongsTo(Task::class);
    }

    public function dpr()
    {
        return $this->belongsTo(DailyProgressReport::class, 'dpr_id');
    }
}
