<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    private $dashboardService;

    public function __construct(DashboardService $dashboardService)
    {
        $this->dashboardService = $dashboardService;
    }

    public function ownerDashboard(Request $request)
    {
        if (!$request->user()->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $dashboard = $this->dashboardService->getOwnerDashboard($request->user()->id);

        return response()->json([
            'success' => true,
            'data' => $dashboard
        ]);
    }

    /**
     * Get dashboard data for manager/site incharge
     */
    public function managerDashboard(Request $request)
    {
        if (!$request->user()->isManager()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $dashboard = $this->dashboardService->getManagerDashboard($request->user()->id);

        return response()->json([
            'success' => true,
            'data' => $dashboard
        ]);
    }

    /**
     * Get dashboard data for worker/engineer
     */
    public function workerDashboard(Request $request)
    {
        if (!$request->user()->isWorker() && !$request->user()->isEngineer()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $dashboard = $this->dashboardService->getWorkerDashboard($request->user()->id);

        return response()->json([
            'success' => true,
            'data' => $dashboard
        ]);
    }

    /**
     * Get time vs cost analysis dashboard
     */
    public function timeVsCost(Request $request)
    {
        if (!$request->user()->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $timeVsCostData = $this->dashboardService->getTimeVsCostDashboard($request->user()->id);

        return response()->json([
            'success' => true,
            'data' => $timeVsCostData
        ]);
    }
}
