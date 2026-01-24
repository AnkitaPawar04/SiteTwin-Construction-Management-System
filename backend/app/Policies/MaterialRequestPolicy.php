<?php

namespace App\Policies;

use App\Models\MaterialRequest;
use App\Models\User;

class MaterialRequestPolicy
{
    public function viewAny(User $user)
    {
        // Purchase Managers can view all material requests
        return true;
    }

    public function view(User $user, MaterialRequest $request)
    {
        // Purchase Managers can view all requests, others need project access
        return $user->isPurchaseManager() || $user->hasAccessToProject($request->project_id);
    }

    public function create(User $user)
    {
        return $user->isWorker() || $user->isEngineer() || $user->isManager() || $user->isOwner();
    }

    public function update(User $user, MaterialRequest $request)
    {
        return $request->requested_by === $user->id 
            && $request->status === MaterialRequest::STATUS_PENDING;
    }

    public function approve(User $user, MaterialRequest $request)
    {
        return ($user->isManager() || $user->isOwner()) && $user->hasAccessToProject($request->project_id);
    }

    public function review(User $user, MaterialRequest $request)
    {
        // Only Purchase Managers can review material requests
        return $user->isPurchaseManager();
    }
}
