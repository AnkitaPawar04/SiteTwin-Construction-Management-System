<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PurchaseOrder extends Model
{
    use HasFactory;

    const STATUS_CREATED = 'created';
    const STATUS_APPROVED = 'approved';
    const STATUS_DELIVERED = 'delivered';
    const STATUS_CLOSED = 'closed';

    const TYPE_GST = 'gst';
    const TYPE_NON_GST = 'non_gst';

    public $timestamps = false;

    protected $fillable = [
        'po_number',
        'project_id',
        'vendor_id',
        'material_request_id',
        'created_by',
        'status',
        'type',
        'total_amount',
        'gst_amount',
        'grand_total',
        'invoice_file',
        'approved_at',
        'delivered_at',
        'closed_at',
    ];

    protected $appends = [
        'project_name',
        'vendor_name',
    ];

    protected function casts(): array
    {
        return [
            'total_amount' => 'decimal:2',
            'gst_amount' => 'decimal:2',
            'grand_total' => 'decimal:2',
            'created_at' => 'datetime',
            'approved_at' => 'datetime',
            'delivered_at' => 'datetime',
            'closed_at' => 'datetime',
        ];
    }

    public function getProjectNameAttribute()
    {
        return $this->project?->name;
    }

    public function getVendorNameAttribute()
    {
        return $this->vendor?->name;
    }

    // Relationships
    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function materialRequest()
    {
        return $this->belongsTo(MaterialRequest::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function items()
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }

    // Helper methods
    public static function generatePONumber()
    {
        $year = date('Y');
        $month = date('m');
        $prefix = "PO{$year}{$month}";
        
        $lastPO = self::where('po_number', 'like', "{$prefix}%")
            ->orderBy('id', 'desc')
            ->first();

        if ($lastPO) {
            $lastNumber = intval(substr($lastPO->po_number, -4));
            $newNumber = $lastNumber + 1;
        } else {
            $newNumber = 1;
        }

        return $prefix . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
    }
}
