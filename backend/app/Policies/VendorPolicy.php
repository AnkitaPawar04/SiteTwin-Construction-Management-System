<?php

namespace App\Policies;

use App\Models\Vendor;
use App\Models\User;

class VendorPolicy
{
    public function viewAny(User $user)
    {
        // Purchase Managers, Managers, and Owners can view vendors
        return $user->isPurchaseManager() || $user->isManager() || $user->isOwner();
    }

    public function view(User $user, Vendor $vendor)
    {
        // Same as viewAny
        return $user->isPurchaseManager() || $user->isManager() || $user->isOwner();
    }

    public function create(User $user)
    {
        // Only Purchase Managers and Managers can create vendors
        return $user->isPurchaseManager() || $user->isManager();
    }

    public function update(User $user, Vendor $vendor)
    {
        // Only Purchase Managers and Managers can update vendors
        return $user->isPurchaseManager() || $user->isManager();
    }

    public function delete(User $user, Vendor $vendor)
    {
        // Only Purchase Managers can delete vendors
        return $user->isPurchaseManager();
    }
}
