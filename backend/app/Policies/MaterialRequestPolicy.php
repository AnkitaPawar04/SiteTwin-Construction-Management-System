<?php

namespace App\Policies;

use App\Models\MaterialRequest;
use App\Models\User;

class MaterialRequestPolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, MaterialRequest $request)
    {
        return $user->hasAccessToProject($request->project_id);
    }

    public function create(User $user)
    {
        return $user->isEngineer() || $user->isManager() || $user->isOwner();
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
}
