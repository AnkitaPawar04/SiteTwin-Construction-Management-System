<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class ToolCheckout extends Model
{
    use HasFactory;

    protected $fillable = [
        'tool_id',
        'checked_out_by',
        'project_id',
        'checkout_time',
        'expected_return_time',
        'actual_return_time',
        'return_condition',
        'verified_by',
        'checkout_notes',
        'return_notes',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'checkout_time' => 'datetime',
            'expected_return_time' => 'datetime',
            'actual_return_time' => 'datetime',
        ];
    }

    // Relationships
    public function tool()
    {
        return $this->belongsTo(Tool::class);
    }

    public function checkedOutBy()
    {
        return $this->belongsTo(User::class, 'checked_out_by');
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    // Helper methods
    public function isOverdue(): bool
    {
        if ($this->status !== 'ACTIVE') {
            return false;
        }

        return Carbon::now()->isAfter($this->expected_return_time);
    }

    public function getDaysOverdue(): int
    {
        if (!$this->isOverdue()) {
            return 0;
        }

        return Carbon::now()->diffInDays($this->expected_return_time);
    }

    public function isReturned(): bool
    {
        return $this->status === 'RETURNED';
    }

    public function wasReturnedOnTime(): bool
    {
        if (!$this->isReturned() || !$this->actual_return_time) {
            return false;
        }

        return $this->actual_return_time->lte($this->expected_return_time);
    }
}
