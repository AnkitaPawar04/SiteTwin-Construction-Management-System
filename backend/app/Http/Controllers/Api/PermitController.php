<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PermitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PermitController extends Controller
{
    private $permitService;

    public function __construct(PermitService $permitService)
    {
        $this->permitService = $permitService;
    }

    /**
     * Request new permit
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
            'task_description' => 'required|string',
            'risk_level' => 'required|in:LOW,MEDIUM,HIGH,CRITICAL',
            'safety_officer_id' => 'nullable|exists:users,id',
            'safety_measures' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $request->all();
            $data['requested_by'] = $request->user()->id;

            $permit = $this->permitService->requestPermit($data);

            return response()->json([
                'success' => true,
                'message' => 'Permit requested successfully',
                'data' => $permit,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Generate OTP for permit
     */
    public function generateOTP($permitId)
    {
        try {
            $result = $this->permitService->generateOTP($permitId);

            return response()->json([
                'success' => true,
                'message' => 'OTP generated and sent',
                'data' => $result,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Verify OTP and approve permit
     */
    public function verifyOTP($permitId, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $permit = $this->permitService->verifyOTP($permitId, $request->otp);

            return response()->json([
                'success' => true,
                'message' => 'Permit approved successfully',
                'data' => $permit,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Reject permit
     */
    public function reject($permitId, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $permit = $this->permitService->rejectPermit($permitId, $request->reason);

            return response()->json([
                'success' => true,
                'message' => 'Permit rejected',
                'data' => $permit,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Start work
     */
    public function startWork($permitId)
    {
        try {
            $permit = $this->permitService->startWork($permitId);

            return response()->json([
                'success' => true,
                'message' => 'Work started',
                'data' => $permit,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Complete work
     */
    public function completeWork($permitId, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'completion_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $permit = $this->permitService->completeWork(
                $permitId,
                $request->user()->id,
                $request->completion_notes
            );

            return response()->json([
                'success' => true,
                'message' => 'Work completed',
                'data' => $permit,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get active permits
     */
    public function getActive(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $permits = $this->permitService->getActivePermits($request->project_id);

            return response()->json(['success' => true, 'data' => $permits]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get critical risk permits
     */
    public function getCriticalRisk(Request $request)
    {
        $projectId = $request->query('project_id');
        
        try {
            $permits = $this->permitService->getCriticalRiskPermits($projectId);

            return response()->json(['success' => true, 'data' => $permits]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get permit statistics
     */
    public function getStatistics(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $stats = $this->permitService->getPermitStatistics(
                $request->project_id,
                $request->start_date,
                $request->end_date
            );

            return response()->json(['success' => true, 'data' => $stats]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
