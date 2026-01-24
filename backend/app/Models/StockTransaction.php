<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockTransaction extends Model
{
    use HasFactory;

    // Transaction types
    const TYPE_IN = 'in';
    const TYPE_OUT = 'out';

    // Reference types
    const REFERENCE_PURCHASE_ORDER = 'purchase_order';
    const REFERENCE_TASK = 'task';
    const REFERENCE_ADJUSTMENT = 'adjustment';

    protected $fillable = [
        'material_id',
        'project_id',
        'transaction_type',
        'quantity',
        'reference_type',
        'reference_id',
        'invoice_id',
        'performed_by',
        'transaction_date',
        'notes',
        'balance_after_transaction',
    ];

    protected $casts = [
        'transaction_date' => 'datetime',
        'quantity' => 'decimal:2',
        'balance_after_transaction' => 'decimal:2',
    ];

    /**
     * Get the material that owns the stock transaction.
     */
    public function material(): BelongsTo
    {
        return $this->belongsTo(Material::class);
    }

    /**
     * Get the project that owns the stock transaction.
     */
    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    /**
     * Get the user who performed the transaction.
     */
    public function performer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'performed_by');
    }

    /**
     * Get the purchase order (polymorphic).
     */
    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(PurchaseOrder::class, 'reference_id')
            ->where('reference_type', self::REFERENCE_PURCHASE_ORDER);
    }

    /**
     * Get the task (polymorphic).
     */
    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class, 'reference_id')
            ->where('reference_type', self::REFERENCE_TASK);
    }

    /**
     * Scope to get only IN transactions.
     */
    public function scopeIn($query)
    {
        return $query->where('transaction_type', self::TYPE_IN);
    }

    /**
     * Scope to get only OUT transactions.
     */
    public function scopeOut($query)
    {
        return $query->where('transaction_type', self::TYPE_OUT);
    }

    /**
     * Scope to filter by material.
     */
    public function scopeForMaterial($query, $materialId)
    {
        return $query->where('material_id', $materialId);
    }

    /**
     * Scope to filter by project.
     */
    public function scopeForProject($query, $projectId)
    {
        return $query->where('project_id', $projectId);
    }

    /**
     * Check if transaction is stock IN.
     */
    public function isStockIn(): bool
    {
        return $this->transaction_type === self::TYPE_IN;
    }

    /**
     * Check if transaction is stock OUT.
     */
    public function isStockOut(): bool
    {
        return $this->transaction_type === self::TYPE_OUT;
    }

    /**
     * Get the signed quantity (positive for IN, negative for OUT).
     */
    public function getSignedQuantityAttribute(): float
    {
        return $this->isStockIn() ? $this->quantity : -$this->quantity;
    }
}
