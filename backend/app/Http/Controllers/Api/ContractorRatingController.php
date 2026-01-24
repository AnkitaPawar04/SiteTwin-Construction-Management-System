<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ContractorRatingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ContractorRatingController extends Controller
{
    private $ratingService;

    public function __construct(ContractorRatingService $ratingService)
    {
        $this->ratingService = $ratingService;
    }

    /**
     * Create or update contractor rating
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'contractor_id' => 'required|exists:users,id',
            'project_id' => 'required|exists:projects,id',
            'rating_period_start' => 'required|date',
            'rating_period_end' => 'required|date|after:rating_period_start',
            'punctuality_score' => 'required|numeric|min:0|max:10',
            'quality_score' => 'required|numeric|min:0|max:10',
            'safety_score' => 'required|numeric|min:0|max:10',
            'wastage_score' => 'required|numeric|min:0|max:10',
            'comments' => 'nullable|string',
            'penalty_base_amount' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $validator->validated();
            $data['rated_by'] = $request->user()->id;

            $rating = $this->ratingService->rateContractor($data);

            return response()->json([
                'success' => true,
                'message' => 'Contractor rated successfully',
                'data' => $rating->load(['contractor', 'project', 'ratedBy']),
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get contractor performance history
     */
    public function getHistory($contractorId, Request $request)
    {
        $projectId = $request->query('project_id');
        
        try {
            $history = $this->ratingService->getContractorHistory($contractorId, $projectId);

            return response()->json(['success' => true, 'data' => $history]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get contractor average rating
     */
    public function getAverageRating($contractorId)
    {
        try {
            $averages = $this->ratingService->getContractorAverageRating($contractorId);

            return response()->json(['success' => true, 'data' => $averages]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get contractors needing attention (poor ratings)
     */
    public function getNeedingAttention(Request $request)
    {
        $threshold = $request->query('threshold', 5.0);
        
        try {
            $contractors = $this->ratingService->getContractorsNeedingAttention($threshold);

            return response()->json(['success' => true, 'data' => $contractors]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
