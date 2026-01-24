<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PettyCashTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'project_id',
        'amount',
        'purpose',
        'description',
        'receipt_image_path',
        'latitude',
        'longitude',
        'gps_validated',
        'requested_by',
        'requested_at',
        'approved_by',
        'approved_at',
        'transaction_date',
        'vendor_name',
        'payment_method',
        'status',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'gps_validated' => 'boolean',
            'requested_at' => 'datetime',
            'approved_at' => 'datetime',
            'transaction_date' => 'date',
        ];
    }

    // Relationships
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

    // Helper methods
    public function validateGPS(float $projectLat, float $projectLng, float $radiusMeters = 500): bool
    {
        if (!$this->latitude || !$this->longitude) {
            return false;
        }

        $distance = $this->calculateDistance(
            $this->latitude,
            $this->longitude,
            $projectLat,
            $projectLng
        );

        $isValid = $distance <= $radiusMeters;

        $this->update(['gps_validated' => $isValid]);

        return $isValid;
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2): float
    {
        $earthRadius = 6371000; // meters

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }

    public function isApproved(): bool
    {
        return $this->status === 'APPROVED';
    }

    public function isPending(): bool
    {
        return $this->status === 'PENDING';
    }

    public function hasReceipt(): bool
    {
        return !empty($this->receipt_image_path);
    }
}
