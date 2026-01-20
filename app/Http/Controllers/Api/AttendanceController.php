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
}
