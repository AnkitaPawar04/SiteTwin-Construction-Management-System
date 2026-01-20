<?php

namespace App\Policies;

use App\Models\Project;
use App\Models\User;

class ProjectPolicy
{
    public function viewAny(User $user)
    {
        return true; // All authenticated users can view their projects
    }

    public function view(User $user, Project $project)
    {
        return $user->hasAccessToProject($project->id);
    }

    public function create(User $user)
    {
        return $user->isOwner() || $user->isManager();
    }

    public function update(User $user, Project $project)
    {
        if ($user->isOwner()) {
            return $project->owner_id === $user->id;
        }
        return $user->isManager() && $user->hasAccessToProject($project->id);
    }

    public function delete(User $user, Project $project)
    {
        return $user->isOwner() && $project->owner_id === $user->id;
    }
}
