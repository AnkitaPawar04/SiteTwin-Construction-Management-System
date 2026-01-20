<?php

namespace App\Policies;

use App\Models\Attendance;
use App\Models\User;

class AttendancePolicy
{
    public function viewAny(User $user)
    {
        return true;
    }

    public function view(User $user, Attendance $attendance)
    {
        return $user->hasAccessToProject($attendance->project_id) 
            || $attendance->user_id === $user->id;
    }

    public function create(User $user)
    {
        return true; // All users can mark attendance
    }

    public function update(User $user, Attendance $attendance)
    {
        // Only the user can update their own attendance
        return $attendance->user_id === $user->id;
    }
}
