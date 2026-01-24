<?php

namespace App\Services;

use App\Models\PettyCashTransaction;
use App\Models\Project;
use Carbon\Carbon;

class PettyCashService
{
    /**
     * Create new petty cash request
     */
    public function createRequest(array $data): PettyCashTransaction
    {
        // Handle receipt image upload
        $receiptImagePath = null;
        if (isset($data['receipt_image'])) {
            $receiptImagePath = $data['receipt_image']->store('petty-cash-receipts', 'public');
        }

        return PettyCashTransaction::create([
            'project_id' => $data['project_id'],
            'amount' => $data['amount'],
            'purpose' => $data['purpose'],
            'description' => $data['description'] ?? null,
            'receipt_image_path' => $receiptImagePath,
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
            'requested_by' => $data['requested_by'],
            'requested_at' => Carbon::now(),
            'transaction_date' => $data['transaction_date'] ?? Carbon::today(),
            'vendor_name' => $data['vendor_name'] ?? null,
            'payment_method' => $data['payment_method'] ?? 'CASH',
            'status' => 'PENDING',
        ]);
    }

    /**
     * Approve petty cash request
     */
    public function approveRequest(int $transactionId, int $approvedBy): PettyCashTransaction
    {
        $transaction = PettyCashTransaction::with('project')->findOrFail($transactionId);

        if ($transaction->status !== 'PENDING') {
            throw new \Exception("Transaction is not pending. Current status: {$transaction->status}");
        }

        // Validate GPS if coordinates provided
        if ($transaction->latitude && $transaction->longitude && $transaction->project) {
            $project = $transaction->project;
            $transaction->validateGPS(
                $project->latitude,
                $project->longitude,
                $project->geofence_radius_meters ?? 500
            );
        }

        $transaction->update([
            'approved_by' => $approvedBy,
            'approved_at' => Carbon::now(),
            'status' => 'APPROVED',
        ]);

        return $transaction->fresh();
    }

    /**
     * Reject petty cash request
     */
    public function rejectRequest(int $transactionId, int $rejectedBy, string $reason): PettyCashTransaction
    {
        $transaction = PettyCashTransaction::findOrFail($transactionId);

        if ($transaction->status !== 'PENDING') {
            throw new \Exception("Transaction is not pending. Current status: {$transaction->status}");
        }

        $transaction->update([
            'approved_by' => $rejectedBy,
            'approved_at' => Carbon::now(),
            'status' => 'REJECTED',
            'rejection_reason' => $reason,
        ]);

        return $transaction->fresh();
    }

    /**
     * Mark as reimbursed
     */
    public function markAsReimbursed(int $transactionId): PettyCashTransaction
    {
        $transaction = PettyCashTransaction::findOrFail($transactionId);

        if ($transaction->status !== 'APPROVED') {
            throw new \Exception("Only approved transactions can be marked as reimbursed");
        }

        $transaction->update(['status' => 'REIMBURSED']);

        return $transaction->fresh();
    }

    /**
     * Get pending requests for approval
     */
    public function getPendingRequests(int $projectId): array
    {
        $requests = PettyCashTransaction::where('project_id', $projectId)
            ->where('status', 'PENDING')
            ->with(['requestedBy', 'project'])
            ->orderBy('requested_at', 'desc')
            ->get();

        return [
            'total_pending' => $requests->count(),
            'total_amount_pending' => $requests->sum('amount'),
            'requests' => $requests,
        ];
    }

    /**
     * Get summary for period
     */
    public function getSummary(int $projectId, string $startDate, string $endDate): array
    {
        $transactions = PettyCashTransaction::where('project_id', $projectId)
            ->whereBetween('transaction_date', [$startDate, $endDate])
            ->with(['requestedBy', 'approvedBy'])
            ->get();

        $approved = $transactions->where('status', 'APPROVED');
        $reimbursed = $transactions->where('status', 'REIMBURSED');

        return [
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'total_transactions' => $transactions->count(),
            'total_requested' => $transactions->sum('amount'),
            'total_approved' => $approved->sum('amount'),
            'total_reimbursed' => $reimbursed->sum('amount'),
            'pending_reimbursement' => $approved->sum('amount') - $reimbursed->sum('amount'),
            'by_payment_method' => [
                'cash' => $approved->where('payment_method', 'CASH')->sum('amount'),
                'upi' => $approved->where('payment_method', 'UPI')->sum('amount'),
                'card' => $approved->where('payment_method', 'CARD')->sum('amount'),
                'cheque' => $approved->where('payment_method', 'CHEQUE')->sum('amount'),
            ],
            'gps_validated_count' => $approved->where('gps_validated', true)->count(),
            'gps_failed_count' => $approved->where('gps_validated', false)->count(),
        ];
    }

    /**
     * Get transactions without receipts
     */
    public function getTransactionsWithoutReceipts(int $projectId): array
    {
        return PettyCashTransaction::where('project_id', $projectId)
            ->where('status', 'APPROVED')
            ->whereNull('receipt_image_path')
            ->with(['requestedBy'])
            ->orderBy('transaction_date', 'desc')
            ->get()
            ->toArray();
    }

    /**
     * Get GPS validation failures
     */
    public function getGPSFailures(int $projectId): array
    {
        return PettyCashTransaction::where('project_id', $projectId)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->where('gps_validated', false)
            ->with(['requestedBy', 'approvedBy'])
            ->orderBy('transaction_date', 'desc')
            ->get()
            ->toArray();
    }
}
