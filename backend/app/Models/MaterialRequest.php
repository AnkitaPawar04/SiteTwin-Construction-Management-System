<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MaterialRequest extends Model
{
    use HasFactory;

    const STATUS_PENDING = 'pending';
    const STATUS_REVIEWED = 'reviewed';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';
    const STATUS_RECEIVED = 'received';

    public $timestamps = false;

    protected $fillable = [
        'project_id',
        'requested_by',
        'approved_by',
        'status',
    ];

    protected $appends = [
        'project_name',
        'requested_by_name',
    ];

    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
        ];
    }

    public function getProjectNameAttribute()
    {
        return $this->project?->name;
    }

    public function getRequestedByNameAttribute()
    {
        return $this->requestedBy?->name;
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function requestedBy()
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function approvedBy()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function items()
    {
        return $this->hasMany(MaterialRequestItem::class, 'request_id');
    }

    public function approval()
    {
        return $this->morphOne(Approval::class, 'reference');
    }

    public function purchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class);
    }
}
