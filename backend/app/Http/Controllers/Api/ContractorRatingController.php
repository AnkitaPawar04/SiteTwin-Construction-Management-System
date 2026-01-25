<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ContractorRatingService;
use App\Models\Contractor;
use App\Models\ContractorTrade;
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
     * Get all contractors with ratings
     */
    public function index()
    {
        $contractors = Contractor::with('trades.ratings')->get();
        
        $contractorsWithRatings = $contractors->map(function ($contractor) {
            $tradeRatings = [];
            
            foreach ($contractor->trades as $trade) {
                $avgSpeed = $trade->ratings->avg('speed');
                $avgQuality = $trade->ratings->avg('quality');
                
                $tradeRatings[] = [
                    'id' => $trade->id,
                    'trade_type' => $trade->trade_type,
                    'average_rating' => round((($avgSpeed ?? 0) + ($avgQuality ?? 0)) / 2, 1),
                    'total_ratings' => $trade->ratings->count(),
                ];
            }
            
            // Overall rating = average of all trade ratings
            $overallRating = 0;
            if (!empty($tradeRatings)) {
                $sumTradeRatings = array_sum(array_column($tradeRatings, 'average_rating'));
                $overallRating = round($sumTradeRatings / count($tradeRatings), 1);
            }
            
            return [
                'id' => $contractor->id,
                'name' => $contractor->name,
                'phone' => $contractor->phone,
                'email' => $contractor->email,
                'address' => $contractor->address,
                'overall_rating' => $overallRating,
                'trades' => $tradeRatings,
            ];
        });
        
        return response()->json([
            'success' => true,
            'data' => $contractorsWithRatings
        ]);
    }

    /**
     * Create contractor
     */
    public function storeContractor(Request $request)
    {
        // Only managers can create contractors
        if ($request->user()->role !== 'manager') {
            return response()->json([
                'success' => false,
                'message' => 'Only managers can create contractors'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'address' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $contractor = Contractor::create($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Contractor created successfully',
            'data' => $contractor
        ], 201);
    }

    /**
     * Get contractor's trades with ratings
     */
    public function getTrades($contractorId)
    {
        $trades = ContractorTrade::where('contractor_id', $contractorId)
            ->with('ratings')
            ->get();
        
        $tradesWithRatings = $trades->map(function ($trade) {
            $avgSpeed = $trade->ratings->avg('speed');
            $avgQuality = $trade->ratings->avg('quality');
            
            return [
                'id' => $trade->id,
                'trade_type' => $trade->trade_type,
                'average_rating' => round((($avgSpeed ?? 0) + ($avgQuality ?? 0)) / 2, 1),
                'total_ratings' => $trade->ratings->count(),
            ];
        });
        
        return response()->json([
            'success' => true,
            'data' => $tradesWithRatings
        ]);
    }

    /**
     * Add trade to contractor
     */
    public function addTrade(Request $request, $contractorId)
    {
        // Only managers can add trades
        if ($request->user()->role !== 'manager') {
            return response()->json([
                'success' => false,
                'message' => 'Only managers can add trades'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'trade_type' => 'required|in:Plumbing,Electrical,Tiling,Painting,Carpentry,Masonry,Plastering,Waterproofing,Flooring,Roofing,HVAC,Other',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $trade = ContractorTrade::create([
                'contractor_id' => $contractorId,
                'trade_type' => $request->trade_type,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Trade added successfully',
                'data' => $trade
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Trade already exists for this contractor'
            ], 422);
        }
    }

    /**
     * Rate a contractor's trade (Manager only)
     */
    public function store(Request $request)
    {
        // Only managers can rate contractors
        if ($request->user()->role !== 'manager') {
            return response()->json([
                'success' => false,
                'message' => 'Only managers can rate contractors'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'contractor_id' => 'required|exists:contractors,id',
            'trade_id' => 'required|exists:contractor_trades,id',
            'project_id' => 'required|exists:projects,id',
            'speed' => 'required|numeric|min:1|max:10',
            'quality' => 'required|numeric|min:1|max:10',
            'comments' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $validator->validated();
            $data['rated_by'] = $request->user()->id;

            $rating = $this->ratingService->rateTrade($data);

            return response()->json([
                'success' => true,
                'message' => 'Trade rated successfully',
                'data' => $rating,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get contractor summary (overall rating + all trades)
     */
    public function getContractorSummary($contractorId)
    {
        try {
            $summary = $this->ratingService->getContractorSummary($contractorId);
            return response()->json(['success' => true, 'data' => $summary]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get project contractor ratings
     */
    public function getProjectRatings($projectId)
    {
        try {
            $ratings = $this->ratingService->getProjectContractorRatings($projectId);
            return response()->json(['success' => true, 'data' => $ratings]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get trade history
     */
    public function getTradeHistory($tradeId, Request $request)
    {
        $projectId = $request->query('project_id');
        
        try {
            $history = $this->ratingService->getTradeHistory($tradeId, $projectId);
            return response()->json(['success' => true, 'data' => $history]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }
}
