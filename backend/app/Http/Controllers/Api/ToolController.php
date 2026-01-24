<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ToolService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ToolController extends Controller
{
    private $toolService;

    public function __construct(ToolService $toolService)
    {
        $this->toolService = $toolService;
    }

    /**
     * Add new tool
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'tool_name' => 'required|string|max:255',
            'tool_code' => 'nullable|string|unique:tools_library,tool_code',
            'qr_code' => 'nullable|string|unique:tools_library,qr_code',
            'category' => 'required|string|max:100',
            'purchase_date' => 'nullable|date',
            'purchase_price' => 'nullable|numeric|min:0',
            'condition' => 'nullable|in:EXCELLENT,GOOD,FAIR,POOR',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $tool = $this->toolService->addTool($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Tool added successfully',
                'data' => $tool,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Checkout tool
     */
    public function checkout(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'tool_id' => 'required|exists:tools_library,id',
            'project_id' => 'required|exists:projects,id',
            'expected_return_time' => 'required|date|after:now',
            'checkout_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $request->all();
            $data['checked_out_by'] = $request->user()->id;

            $checkout = $this->toolService->checkoutTool($data);

            return response()->json([
                'success' => true,
                'message' => 'Tool checked out successfully',
                'data' => $checkout,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Return tool
     */
    public function return($checkoutId, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'return_condition' => 'required|in:EXCELLENT,GOOD,FAIR,POOR,DAMAGED',
            'return_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $request->all();
            $data['verified_by'] = $request->user()->id;

            $checkout = $this->toolService->returnTool($checkoutId, $data);

            return response()->json([
                'success' => true,
                'message' => 'Tool returned successfully',
                'data' => $checkout,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get overdue tools
     */
    public function getOverdue(Request $request)
    {
        $projectId = $request->query('project_id');
        
        try {
            $overdueTools = $this->toolService->getOverdueTools($projectId);

            return response()->json(['success' => true, 'data' => $overdueTools]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get availability report
     */
    public function getAvailabilityReport()
    {
        try {
            $report = $this->toolService->getAvailabilityReport();

            return response()->json(['success' => true, 'data' => $report]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get tool history
     */
    public function getHistory($toolId)
    {
        try {
            $history = $this->toolService->getToolHistory($toolId);

            return response()->json(['success' => true, 'data' => $history]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Mark tool as lost
     */
    public function markAsLost($checkoutId)
    {
        try {
            $this->toolService->markAsLost($checkoutId);

            return response()->json([
                'success' => true,
                'message' => 'Tool marked as lost',
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
