<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PermitToWork;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PermitToWorkController extends Controller
{
    /**
     * Get all permits (with role-based filtering)
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        
        $query = PermitToWork::with(['project', 'supervisor', 'approver']);

        // Supervisors see only their permits
        if ($user->role === 'supervisor') {
            $query->where('supervisor_id', $user->id);
        }
        
        // Safety Officers see only permits they need to approve
        elseif ($user->role === 'safety_officer') {
            $query->where('status', PermitToWork::STATUS_PENDING)
                  ->orWhere('approved_by', $user->id);
        }

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by project if provided
        if ($request->has('project_id')) {
            $query->where('project_id', $request->project_id);
        }

        $permits = $query->latest()->get();

        return response()->json([
            'success' => true,
            'data' => $permits
        ]);
    }

    /**
     * Get single permit
     */
    public function show($id)
    {
        $permit = PermitToWork::with(['project', 'supervisor', 'approver'])->findOrFail($id);
        
        // Authorization check
        $user = auth()->user();
        if ($user->role === 'supervisor' && $permit->supervisor_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to view this permit'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $permit
        ]);
    }

    /**
     * Request permit (Supervisor only)
     */
    public function requestPermit(Request $request)
    {
        $user = auth()->user();

        if ($user->role !== 'supervisor') {
            return response()->json([
                'success' => false,
                'message' => 'Only supervisors can request permits'
            ], 403);
        }

        $validated = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'task_type' => 'required|in:HEIGHT,ELECTRICAL,WELDING,CONFINED_SPACE,HOT_WORK,EXCAVATION',
            'description' => 'required|string|min:10',
            'safety_measures' => 'required|string|min:10',
            'notes' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            $permit = PermitToWork::create([
                'project_id' => $validated['project_id'],
                'task_type' => $validated['task_type'],
                'description' => $validated['description'],
                'safety_measures' => $validated['safety_measures'],
                'supervisor_id' => $user->id,
                'requested_at' => Carbon::now(),
                'status' => PermitToWork::STATUS_PENDING,
                'notes' => $validated['notes'] ?? null,
                'otp_code' => PermitToWork::FIXED_OTP,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Permit requested successfully. Waiting for Safety Officer approval.',
                'data' => $permit->load(['project', 'supervisor'])
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to request permit: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Approve permit (Safety Officer only)
     */
    public function approvePermit(Request $request, $id)
    {
        $user = auth()->user();

        if ($user->role !== 'safety_officer') {
            return response()->json([
                'success' => false,
                'message' => 'Only safety officers can approve permits'
            ], 403);
        }

        $permit = PermitToWork::findOrFail($id);

        if ($permit->status !== PermitToWork::STATUS_PENDING) {
            return response()->json([
                'success' => false,
                'message' => 'Permit is not in pending status'
            ], 422);
        }

        try {
            DB::beginTransaction();

            $permit->update([
                'approved_by' => $user->id,
                'approved_at' => Carbon::now(),
                'status' => PermitToWork::STATUS_APPROVED,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Permit approved. OTP: ' . PermitToWork::FIXED_OTP,
                'data' => $permit->load(['project', 'supervisor', 'approver']),
                'otp' => PermitToWork::FIXED_OTP
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve permit: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Reject permit (Safety Officer only)
     */
    public function rejectPermit(Request $request, $id)
    {
        $user = auth()->user();

        if ($user->role !== 'safety_officer') {
            return response()->json([
                'success' => false,
                'message' => 'Only safety officers can reject permits'
            ], 403);
        }

        $validated = $request->validate([
            'rejection_reason' => 'required|string',
        ]);

        $permit = PermitToWork::findOrFail($id);

        if ($permit->status !== PermitToWork::STATUS_PENDING) {
            return response()->json([
                'success' => false,
                'message' => 'Permit is not in pending status'
            ], 422);
        }

        try {
            DB::beginTransaction();

            $permit->update([
                'safety_officer_id' => $user->id,
                'status' => PermitToWork::STATUS_REJECTED,
                'rejection_reason' => $validated['rejection_reason'],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Permit rejected',
                'data' => $permit->load(['project', 'supervisor', 'approver'])
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to reject permit: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Verify OTP and start work (Supervisor only)
     */
    public function verifyOTP(Request $request, $id)
    {
        $user = auth()->user();

        if ($user->role !== 'supervisor') {
            return response()->json([
                'success' => false,
                'message' => 'Only supervisors can verify OTP and start work'
            ], 403);
        }

        $validated = $request->validate([
            'otp' => 'required|string|size:6',
        ]);

        $permit = PermitToWork::findOrFail($id);

        // Check ownership
        if ($permit->supervisor_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to verify this permit'
            ], 403);
        }

        if ($permit->status !== PermitToWork::STATUS_APPROVED) {
            return response()->json([
                'success' => false,
                'message' => 'Permit is not approved yet'
            ], 422);
        }

        if (!$permit->verifyOTP($validated['otp'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid OTP'
            ], 422);
        }

        try {
            DB::beginTransaction();

            $permit->update([
                'started_at' => Carbon::now(),
                'status' => PermitToWork::STATUS_IN_PROGRESS,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'OTP verified. Work started successfully.',
                'data' => $permit->load(['project', 'supervisor', 'approver'])
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to start work: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Complete work (Supervisor only)
     */
    public function completeWork(Request $request, $id)
    {
        $user = auth()->user();

        if ($user->role !== 'supervisor') {
            return response()->json([
                'success' => false,
                'message' => 'Only supervisors can complete work'
            ], 403);
        }

        $permit = PermitToWork::findOrFail($id);

        // Check ownership
        if ($permit->supervisor_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to complete this permit'
            ], 403);
        }

        if ($permit->status !== PermitToWork::STATUS_IN_PROGRESS) {
            return response()->json([
                'success' => false,
                'message' => 'Work is not in progress'
            ], 422);
        }

        try {
            DB::beginTransaction();

            $permit->update([
                'completed_at' => Carbon::now(),
                'status' => PermitToWork::STATUS_COMPLETED,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Work completed successfully',
                'data' => $permit->load(['project', 'supervisor', 'approver'])
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to complete work: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get permit statistics
     */
    public function statistics()
    {
        $user = auth()->user();

        $query = PermitToWork::query();

        if ($user->role === 'supervisor') {
            $query->where('supervisor_id', $user->id);
        } elseif ($user->role === 'safety_officer') {
            $query->where('safety_officer_id', $user->id);
        }

        $stats = [
            'total' => $query->count(),
            'pending' => (clone $query)->where('status', PermitToWork::STATUS_PENDING)->count(),
            'approved' => (clone $query)->where('status', PermitToWork::STATUS_APPROVED)->count(),
            'in_progress' => (clone $query)->where('status', PermitToWork::STATUS_IN_PROGRESS)->count(),
            'completed' => (clone $query)->where('status', PermitToWork::STATUS_COMPLETED)->count(),
            'rejected' => (clone $query)->where('status', PermitToWork::STATUS_REJECTED)->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}
