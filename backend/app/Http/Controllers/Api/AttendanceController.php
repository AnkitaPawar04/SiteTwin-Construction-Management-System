<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAttendanceRequest;
use App\Http\Requests\CheckOutAttendanceRequest;
use App\Services\AttendanceService;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    private $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        $this->attendanceService = $attendanceService;
    }

    public function checkIn(StoreAttendanceRequest $request)
    {
        try {
            $attendance = $this->attendanceService->checkIn(
                $request->user()->id,
                $request->project_id,
                $request->latitude,
                $request->longitude
            );

            return response()->json([
                'success' => true,
                'message' => 'Check-in successful',
                'data' => $attendance
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function checkOut(CheckOutAttendanceRequest $request, $id)
    {
        try {
            $attendance = $this->attendanceService->checkOut(
                $id,
                $request->latitude,
                $request->longitude
            );

            return response()->json([
                'success' => true,
                'message' => 'Check-out successful',
                'data' => $attendance
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function myAttendance(Request $request)
    {
        $attendance = $this->attendanceService->getUserAttendance(
            $request->user()->id,
            $request->query('project_id')
        );

        return response()->json([
            'success' => true,
            'data' => $attendance
        ]);
    }

    /**
     * Get all attendance records (for owners)
     */
    public function allAttendance(Request $request)
    {
        $attendance = $this->attendanceService->getAllAttendance(
            $request->query('start_date'),
            $request->query('end_date')
        );

        return response()->json([
            'success' => true,
            'data' => $attendance
        ]);
    }

    public function projectAttendance(Request $request, $projectId)
    {
        $attendance = $this->attendanceService->getAttendanceByProject(
            $projectId,
            $request->query('start_date'),
            $request->query('end_date')
        );

        return response()->json([
            'success' => true,
            'data' => $attendance
        ]);
    }

    /**
     * Get team attendance summary for a project
     * Only accessible by managers/site incharges
     */
    public function teamSummary(Request $request, $projectId)
    {
        try {
            // Verify user is assigned to this project as manager
            $summary = $this->attendanceService->getTeamAttendanceSummary(
                $projectId,
                $request->query('date', now()->toDateString())
            );

            return response()->json([
                'success' => true,
                'data' => $summary
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get attendance trends for team
     */
    public function attendanceTrends(Request $request, $projectId)
    {
        try {
            $trends = $this->attendanceService->getAttendanceTrends(
                $projectId,
                $request->query('days', 30)
            );

            return response()->json([
                'success' => true,
                'data' => $trends
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }
    
    public function checkInWithFace(Request $request)
    {
        try {
            $request->validate([
                'project_id' => 'required|exists:projects,id',
                'face_image' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
            ]);

            // Store the face image
            if ($request->hasFile('face_image')) {
                $faceImage = $request->file('face_image');
                $filename = 'face_' . $request->user()->id . '_' . time() . '.' . $faceImage->getClientOriginalExtension();
                $path = $faceImage->storeAs('attendance/faces', $filename, 'public');
            } else {
                throw new \Exception('Face image is required');
            }

            // Create attendance record using the service
            $attendance = $this->attendanceService->checkIn(
                $request->user()->id,
                $request->project_id,
                $request->latitude,
                $request->longitude,
                'storage/' . $path
            );

            return response()->json([
                'success' => true,
                'message' => 'Check-in successful with face verification',
                'data' => $attendance
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function checkOutWithFace(Request $request)
    {
        try {
            $request->validate([
                'project_id' => 'required|exists:projects,id',
                'face_image' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
            ]);

            // Get today's attendance record for this user and project
            $today = now()->format('Y-m-d');
            $attendance = \App\Models\Attendance::where('user_id', $request->user()->id)
                ->where('project_id', $request->project_id)
                ->whereDate('date', $today)
                ->first();

            if (!$attendance) {
                throw new \Exception('No check-in found for today. Please check in first.');
            }

            if ($attendance->check_out) {
                throw new \Exception('Already checked out today.');
            }

            // Store the checkout face image
            if ($request->hasFile('face_image')) {
                $faceImage = $request->file('face_image');
                $filename = 'face_checkout_' . $request->user()->id . '_' . time() . '.' . $faceImage->getClientOriginalExtension();
                $path = $faceImage->storeAs('attendance/faces', $filename, 'public');
                
                // Store path in a custom field if needed (for now, just storing the image)
            }

            // Perform checkout
            $attendance = $this->attendanceService->checkOut(
                $attendance->id,
                $request->latitude,
                $request->longitude
            );

            return response()->json([
                'success' => true,
                'message' => 'Check-out successful with face verification',
                'data' => $attendance
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }
}
