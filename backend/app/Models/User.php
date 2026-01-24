<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    const ROLE_WORKER = 'worker';
    const ROLE_ENGINEER = 'engineer';
    const ROLE_MANAGER = 'manager';
    const ROLE_OWNER = 'owner';
    const ROLE_PURCHASE_MANAGER = 'purchase_manager';

    public $timestamps = false;

    protected $fillable = [
        'name',
        'phone',
        'role',
        'language',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'created_at' => 'datetime',
        ];
    }

    // Relationships
    public function ownedProjects()
    {
        return $this->hasMany(Project::class, 'owner_id');
    }

    public function projects()
    {
        return $this->belongsToMany(Project::class, 'project_users');
    }

    public function attendance()
    {
        return $this->hasMany(Attendance::class);
    }

    public function assignedTasks()
    {
        return $this->hasMany(Task::class, 'assigned_to');
    }

    public function createdTasks()
    {
        return $this->hasMany(Task::class, 'assigned_by');
    }

    public function dailyProgressReports()
    {
        return $this->hasMany(DailyProgressReport::class);
    }

    public function materialRequests()
    {
        return $this->hasMany(MaterialRequest::class, 'requested_by');
    }

    public function approvedMaterialRequests()
    {
        return $this->hasMany(MaterialRequest::class, 'approved_by');
    }

    public function approvals()
    {
        return $this->hasMany(Approval::class, 'approved_by');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function offlineSyncLogs()
    {
        return $this->hasMany(OfflineSyncLog::class);
    }

    // Helper methods
    public function isWorker()
    {
        return $this->role === self::ROLE_WORKER;
    }

    public function isEngineer()
    {
        return $this->role === self::ROLE_ENGINEER;
    }

    public function isManager()
    {
        return $this->role === self::ROLE_MANAGER;
    }

    public function isOwner()
    {
        return $this->role === self::ROLE_OWNER;
    }

    public function isPurchaseManager()
    {
        return $this->role === self::ROLE_PURCHASE_MANAGER;
    }

    public function hasAccessToProject($projectId)
    {
        if ($this->isOwner()) {
            return $this->ownedProjects()->where('id', $projectId)->exists();
        }
        return $this->projects()->where('projects.id', $projectId)->exists();
    }
}
