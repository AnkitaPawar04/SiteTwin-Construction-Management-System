<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'name',
        'location',
        'description',
        'latitude',
        'longitude',
        'geofence_radius_meters',
        'start_date',
        'end_date',
        'owner_id',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'start_date' => 'date',
            'end_date' => 'date',
            'created_at' => 'datetime',
        ];
    }

    // Relationships
    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'project_users');
    }

    public function attendance()
    {
        return $this->hasMany(Attendance::class);
    }

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    public function dailyProgressReports()
    {
        return $this->hasMany(DailyProgressReport::class);
    }

    public function materialRequests()
    {
        return $this->hasMany(MaterialRequest::class);
    }

    public function stock()
    {
        return $this->hasMany(Stock::class);
    }

    public function stockTransactions()
    {
        return $this->hasMany(StockTransaction::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    // PHASE 4: Costing relationships
    public function consumptionStandards()
    {
        return $this->hasMany(MaterialConsumptionStandard::class);
    }

    public function projectUnits()
    {
        return $this->hasMany(ProjectUnit::class);
    }

    public function purchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class);
    }

    // PHASE 5: Advanced field & compliance relationships
    public function contractorRatings()
    {
        return $this->hasMany(ContractorRating::class);
    }

    public function dailyWagerAttendance()
    {
        return $this->hasMany(DailyWagerAttendance::class);
    }

    public function permits()
    {
        return $this->hasMany(PermitToWork::class);
    }

    public function pettyCashTransactions()
    {
        return $this->hasMany(PettyCashTransaction::class);
    }
}