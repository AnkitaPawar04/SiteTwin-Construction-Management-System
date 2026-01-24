<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tool extends Model
{
    use HasFactory;

    protected $table = 'tools_library';

    protected $fillable = [
        'tool_name',
        'tool_code',
        'qr_code',
        'category',
        'current_status',
        'current_holder_id',
        'current_project_id',
        'purchase_date',
        'purchase_price',
        'condition',
        'description',
    ];

    protected function casts(): array
    {
        return [
            'purchase_date' => 'date',
            'purchase_price' => 'decimal:2',
        ];
    }

    // Relationships
    public function currentHolder()
    {
        return $this->belongsTo(User::class, 'current_holder_id');
    }

    public function currentProject()
    {
        return $this->belongsTo(Project::class, 'current_project_id');
    }

    public function checkouts()
    {
        return $this->hasMany(ToolCheckout::class);
    }

    public function activeCheckout()
    {
        return $this->hasOne(ToolCheckout::class)->where('status', 'ACTIVE');
    }

    // Helper methods
    public function isAvailable(): bool
    {
        return $this->current_status === 'AVAILABLE';
    }

    public function isCheckedOut(): bool
    {
        return $this->current_status === 'CHECKED_OUT';
    }

    public function needsMaintenance(): bool
    {
        return $this->current_status === 'MAINTENANCE' || $this->condition === 'POOR';
    }

    public function generateQRCode(): string
    {
        return 'TOOL-' . str_pad($this->id, 6, '0', STR_PAD_LEFT);
    }
}
