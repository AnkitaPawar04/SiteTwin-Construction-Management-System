<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PettyCashService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PettyCashController extends Controller
{
    private $cashService;

    public function __construct(PettyCashService $cashService)
    {
        $this->cashService = $cashService;
    }

    /**
     * Create petty cash request
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
            'amount' => 'required|numeric|min:0',
            'purpose' => 'required|string|max:255',
            'description' => 'nullable|string',
            'receipt_image' => 'nullable|image|max:5120',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'transaction_date' => 'nullable|date',
            'vendor_name' => 'nullable|string|max:255',
            'payment_method' => 'nullable|in:CASH,UPI,CARD,CHEQUE',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $request->all();
            $data['requested_by'] = $request->user()->id;

            $transaction = $this->cashService->createRequest($data);

            return response()->json([
                'success' => true,
                'message' => 'Petty cash request created',
                'data' => $transaction,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Approve request
     */
    public function approve($transactionId, Request $request)
    {
        try {
            $transaction = $this->cashService->approveRequest($transactionId, $request->user()->id);

            return response()->json([
                'success' => true,
                'message' => 'Request approved',
                'data' => $transaction,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Reject request
     */
    public function reject($transactionId, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $transaction = $this->cashService->rejectRequest(
                $transactionId,
                $request->user()->id,
                $request->reason
            );

            return response()->json([
                'success' => true,
                'message' => 'Request rejected',
                'data' => $transaction,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Mark as reimbursed
     */
    public function markReimbursed($transactionId)
    {
        try {
            $transaction = $this->cashService->markAsReimbursed($transactionId);

            return response()->json([
                'success' => true,
                'message' => 'Marked as reimbursed',
                'data' => $transaction,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get pending requests
     */
    public function getPending(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $pending = $this->cashService->getPendingRequests($request->project_id);

            return response()->json(['success' => true, 'data' => $pending]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get summary
     */
    public function getSummary(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $summary = $this->cashService->getSummary(
                $request->project_id,
                $request->start_date,
                $request->end_date
            );

            return response()->json(['success' => true, 'data' => $summary]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get transactions without receipts
     */
    public function getWithoutReceipts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $transactions = $this->cashService->getTransactionsWithoutReceipts($request->project_id);

            return response()->json(['success' => true, 'data' => $transactions]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get GPS validation failures
     */
    public function getGPSFailures(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $failures = $this->cashService->getGPSFailures($request->project_id);

            return response()->json(['success' => true, 'data' => $failures]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
