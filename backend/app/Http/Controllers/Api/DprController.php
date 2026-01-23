<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDprRequest;
use App\Http\Requests\ApproveDprRequest;
use App\Models\DailyProgressReport;
use App\Services\DprService;
use Illuminate\Http\Request;

class DprController extends Controller
{
    private $dprService;

    public function __construct(DprService $dprService)
    {
        $this->dprService = $dprService;
    }

    public function index(Request $request)
    {
        if ($request->has('project_id')) {
            $dprs = $this->dprService->getDprsByProject(
                $request->query('project_id'),
                $request->query('start_date'),
                $request->query('end_date')
            );
        } else {
            $dprs = DailyProgressReport::where('user_id', $request->user()->id)
                ->with(['project', 'photos'])
                ->orderBy('report_date', 'desc')
                ->get();
        }

        return response()->json([
            'success' => true,
            'data' => $dprs
        ]);
    }

    public function store(StoreDprRequest $request)
    {
        $this->authorize('create', DailyProgressReport::class);

        try {
            $dpr = $this->dprService->createDpr(
                $request->user()->id,
                $request->project_id,
                $request->work_description,
                $request->latitude,
                $request->longitude,
                $request->photos ?? [],
                $request->task_id ?? null
            );

            return response()->json([
                'success' => true,
                'message' => 'DPR submitted successfully',
                'data' => $dpr
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
        $dpr = DailyProgressReport::with(['project', 'user', 'photos'])->findOrFail($id);
        $this->authorize('view', $dpr);

        return response()->json([
            'success' => true,
            'data' => $dpr
        ]);
    }

    public function approve(ApproveDprRequest $request, $id)
    {
        $dpr = DailyProgressReport::findOrFail($id);
        $this->authorize('approve', $dpr);

        try {
            $dpr = $this->dprService->approveDpr(
                $id,
                $request->user()->id,
                $request->status
            );

            return response()->json([
                'success' => true,
                'message' => 'DPR ' . $request->status . ' successfully',
                'data' => $dpr
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
            'remarks' => 'nullable|string|max:500'
        ]);

        $dpr = DailyProgressReport::findOrFail($id);
        $this->authorize('approve', $dpr);

        try {
            $dpr = $this->dprService->updateDprStatus(
                $id,
                $request->user()->id,
                $request->status,
                $request->remarks
            );

            return response()->json([
                'success' => true,
                'message' => 'DPR ' . $request->status . ' successfully',
                'data' => $dpr
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
        $projectId = $request->query('project_id');
        $user = $request->user();

        $query = DailyProgressReport::where('status', DailyProgressReport::STATUS_SUBMITTED)
            ->with(['project', 'user', 'photos']);

        // Filter by user's accessible projects
        if ($user->isOwner()) {
            // Owners can see all DPRs for their owned projects
            $projectIds = $user->ownedProjects()->pluck('projects.id')->toArray();
            if (!empty($projectIds)) {
                $query->whereIn('project_id', $projectIds);
            } else {
                $query->whereRaw('1=0'); // No projects, no DPRs
            }
        } elseif ($user->isManager()) {
            // Managers can see all DPRs for their assigned projects
            $projectIds = $user->projects()->pluck('projects.id')->toArray();
            if (!empty($projectIds)) {
                $query->whereIn('project_id', $projectIds);
            } else {
                $query->whereRaw('1=0'); // No projects, no DPRs
            }
        } else {
            // Workers/Engineers can only see their own DPRs
            $query->where('user_id', $user->id);
        }

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        $dprs = $query->orderBy('report_date', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $dprs
        ]);
    }

    public function getPhoto($dprId, $photoId)
    {
        try {
            $dpr = DailyProgressReport::findOrFail($dprId);
            $photo = $dpr->photos()->where('id', $photoId)->firstOrFail();

            $filePath = storage_path('app/public/' . $photo->photo_url);

            if (!file_exists($filePath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Photo not found'
                ], 404);
            }

            return response()->file($filePath);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Not found'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving photo'
            ], 500);
        }
    }
}
