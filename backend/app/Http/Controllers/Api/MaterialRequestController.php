<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMaterialRequestRequest;
use App\Http\Requests\ApproveMaterialRequestRequest;
use App\Models\MaterialRequest;
use App\Services\MaterialRequestService;
use Illuminate\Http\Request;

class MaterialRequestController extends Controller
{
    private $materialRequestService;

    public function __construct(MaterialRequestService $materialRequestService)
    {
        $this->materialRequestService = $materialRequestService;
    }

    public function index(Request $request)
    {
        // Workers and engineers can only see their own requests
        if ($request->user()->isWorker() || $request->user()->isEngineer()) {
            $requests = MaterialRequest::where('requested_by', $request->user()->id)
                ->with(['items.material', 'project'])
                ->orderBy('created_at', 'desc')
                ->get();
        } else {
            // Managers and owners can see all requests for their projects
            if ($request->has('project_id')) {
                $requests = $this->materialRequestService->getMaterialRequestsByProject(
                    $request->query('project_id')
                );
            } else {
                $requests = MaterialRequest::with(['items.material', 'project'])
                    ->orderBy('created_at', 'desc')
                    ->get();
            }
        }

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    public function store(StoreMaterialRequestRequest $request)
    {
        $this->authorize('create', MaterialRequest::class);

        try {
            $materialRequest = $this->materialRequestService->createMaterialRequest(
                $request->project_id,
                $request->user()->id,
                $request->items
            );

            return response()->json([
                'success' => true,
                'message' => 'Material request created successfully',
                'data' => $materialRequest
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function show($id)
    {
        $request = MaterialRequest::with(['items.material', 'project', 'requestedBy', 'approvedBy'])
            ->findOrFail($id);
        $this->authorize('view', $request);

        return response()->json([
            'success' => true,
            'data' => $request
        ]);
    }

    public function approve(ApproveMaterialRequestRequest $request, $id)
    {
        $materialRequest = MaterialRequest::findOrFail($id);
        $this->authorize('approve', $materialRequest);

        try {
            $materialRequest = $this->materialRequestService->approveMaterialRequest(
                $id,
                $request->user()->id,
                $request->status
            );

            return response()->json([
                'success' => true,
                'message' => 'Material request ' . $request->status . ' successfully',
                'data' => $materialRequest
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:approved,rejected',
            'remarks' => 'nullable|string|max:500',
            'allocated_items' => 'nullable|array'
        ]);

        $materialRequest = MaterialRequest::findOrFail($id);
        $this->authorize('approve', $materialRequest);

        try {
            $materialRequest = $this->materialRequestService->updateRequestStatus(
                $id,
                $request->user()->id,
                $request->status,
                $request->remarks,
                $request->allocated_items ?? []
            );

            return response()->json([
                'success' => true,
                'message' => 'Material request ' . $request->status . ' successfully',
                'data' => $materialRequest
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function pending(Request $request)
    {
        // Only managers and owners can see pending requests
        if (!$request->user()->isManager() && !$request->user()->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $projectId = $request->query('project_id');

        $query = MaterialRequest::where('status', MaterialRequest::STATUS_PENDING)
            ->with(['items.material', 'project', 'requestedBy']);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        $requests = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }
    public function receive(Request $request, $id)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*' => 'required|integer|min:0'
        ]);

        $materialRequest = MaterialRequest::findOrFail($id);

        // Only engineers or managers can confirm reception
        if (!$request->user()->isEngineer() && !$request->user()->isManager()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        try {
            $materialRequest = $this->materialRequestService->receiveMaterialRequest(
                $id,
                $request->items
            );

            return response()->json([
                'success' => true,
                'message' => 'Material received and added to stock successfully',
                'data' => $materialRequest
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }
}
