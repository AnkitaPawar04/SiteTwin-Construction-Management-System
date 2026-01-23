<?php

namespace App\Policies;

use App\Models\DailyProgressReport;
use App\Models\User;

class DailyProgressReportPolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, DailyProgressReport $dpr)
    {
        return $user->hasAccessToProject($dpr->project_id);
    }

    public function create(User $user)
    {
        return true; // All users can create DPR
    }

    public function update(User $user, DailyProgressReport $dpr)
    {
        // Only owner can edit their own submitted DPR
        return $dpr->user_id === $user->id && $dpr->status === DailyProgressReport::STATUS_SUBMITTED;
    }

    public function approve(User $user, DailyProgressReport $dpr)
    {
        return ($user->isOwner() || $user->isManager()) 
            && $user->hasAccessToProject($dpr->project_id);
    }
}
