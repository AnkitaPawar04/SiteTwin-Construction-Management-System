<?php

namespace App\Policies;

use App\Models\PurchaseOrder;
use App\Models\User;

class PurchaseOrderPolicy
{
    public function viewAny(User $user)
    {
        // Purchase Managers, Managers, and Owners can view purchase orders
        return $user->isPurchaseManager() || $user->isManager() || $user->isOwner();
    }

    public function view(User $user, PurchaseOrder $purchaseOrder)
    {
        // Purchase Managers can view all, others need project access
        return $user->isPurchaseManager() 
            || ($user->hasAccessToProject($purchaseOrder->project_id) && ($user->isManager() || $user->isOwner()));
    }

    public function create(User $user)
    {
        // Only Purchase Managers can create purchase orders
        return $user->isPurchaseManager();
    }

    public function update(User $user, PurchaseOrder $purchaseOrder)
    {
        // Only Purchase Managers can update purchase orders
        return $user->isPurchaseManager();
    }

    public function delete(User $user, PurchaseOrder $purchaseOrder)
    {
        // Only Purchase Managers can delete purchase orders (only in 'created' status)
        return $user->isPurchaseManager() && $purchaseOrder->status === PurchaseOrder::STATUS_CREATED;
    }

    public function updateStatus(User $user, PurchaseOrder $purchaseOrder)
    {
        // Purchase Managers and Managers can update status
        return $user->isPurchaseManager() || $user->isManager();
    }

    public function uploadInvoice(User $user, PurchaseOrder $purchaseOrder)
    {
        // Only Purchase Managers can upload vendor invoices
        return $user->isPurchaseManager();
    }
}
