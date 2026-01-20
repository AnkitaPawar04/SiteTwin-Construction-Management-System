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
}
