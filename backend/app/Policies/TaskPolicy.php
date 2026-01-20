<?php

namespace App\Policies;

use App\Models\Task;
use App\Models\User;

class TaskPolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, Task $task)
    {
        return $user->hasAccessToProject($task->project_id);
    }

    public function create(User $user)
    {
        return $user->isManager() || $user->isEngineer();
    }

    public function update(User $user, Task $task)
    {
        // Manager/Engineer can update any task in their project
        if ($user->isManager() || $user->isEngineer()) {
            return $user->hasAccessToProject($task->project_id);
        }
        
        // Worker can update only their assigned tasks (status only)
        return $task->assigned_to === $user->id;
    }

    public function delete(User $user, Task $task)
    {
        return ($user->isManager() || $user->isEngineer()) 
            && $user->hasAccessToProject($task->project_id);
    }
}
