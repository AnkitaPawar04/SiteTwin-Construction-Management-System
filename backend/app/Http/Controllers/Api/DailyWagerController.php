<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\DailyWagerService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class DailyWagerController extends Controller
{
    private $wagerService;

    public function __construct(DailyWagerService $wagerService)
    {
        $this->wagerService = $wagerService;
    }

    /**
     * Check-in wager with face recognition
     */
    public function checkIn(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'wager_name' => 'required|string|max:255',
            'wager_phone' => 'nullable|string|max:20',
            'project_id' => 'required|exists:projects,id',
            'attendance_date' => 'nullable|date',
            'face_image' => 'nullable|image|max:5120',
            'face_encoding' => 'nullable|string',
            'wage_rate_per_hour' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $attendance = $this->wagerService->checkIn($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Check-in successful',
                'data' => $attendance,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Check-out wager
     */
    public function checkOut($attendanceId)
    {
        try {
            $attendance = $this->wagerService->checkOut($attendanceId);

            return response()->json([
                'success' => true,
                'message' => 'Check-out successful',
                'data' => $attendance,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Verify attendance
     */
    public function verify($attendanceId, Request $request)
    {
        try {
            $attendance = $this->wagerService->verifyAttendance($attendanceId, $request->user()->id);

            return response()->json([
                'success' => true,
                'message' => 'Attendance verified',
                'data' => $attendance,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Reject attendance
     */
    public function reject($attendanceId, Request $request)
    {
        try {
            $attendance = $this->wagerService->rejectAttendance($attendanceId, $request->user()->id);

            return response()->json([
                'success' => true,
                'message' => 'Attendance rejected',
                'data' => $attendance,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get daily attendance report
     */
    public function getDailyReport(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'project_id' => 'required|exists:projects,id',
            'date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $report = $this->wagerService->getDailyReport(
                $request->project_id,
                $request->date
            );

            return response()->json(['success' => true, 'data' => $report]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get wage summary
     */
    public function getWageSummary(Request $request)
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
            $summary = $this->wagerService->getWageSummary(
                $request->project_id,
                $request->start_date,
                $request->end_date
            );

            return response()->json(['success' => true, 'data' => $summary]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
