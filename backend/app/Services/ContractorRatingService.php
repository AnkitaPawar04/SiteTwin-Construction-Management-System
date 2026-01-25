<?php

namespace App\Services;

use App\Models\ContractorRating;
use App\Models\Contractor;
use App\Models\ContractorTrade;
use Illuminate\Support\Facades\DB;

class ContractorRatingService
{
    /**
     * Create or update trade rating
     * Rating logic: trade_rating = (speed + quality) / 2
     */
    public function rateTrade(array $data): ContractorRating
    {
        $rating = ContractorRating::updateOrCreate(
            [
                'trade_id' => $data['trade_id'],
                'project_id' => $data['project_id'],
            ],
            [
                'contractor_id' => $data['contractor_id'],
                'speed' => $data['speed'],
                'quality' => $data['quality'],
                'rated_by' => $data['rated_by'],
                'comments' => $data['comments'] ?? null,
            ]
        );

        return $rating->fresh(['trade', 'contractor', 'project', 'ratedBy']);
    }

    /**
     * Get contractor overall rating (average of all trade ratings)
     */
    public function getContractorOverallRating(int $contractorId, ?int $projectId = null): float
    {
        $query = ContractorRating::where('contractor_id', $contractorId);
        
        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        $ratings = $query->get();
        
        if ($ratings->isEmpty()) {
            return 0;
        }

        // Calculate average of all trade ratings
        // Each trade rating = (speed + quality) / 2
        $totalRating = $ratings->sum(function ($rating) {
            return ($rating->speed + $rating->quality) / 2;
        });

        return round($totalRating / $ratings->count(), 1);
    }

    /**
     * Get trade performance history
     */
    public function getTradeHistory(int $tradeId, ?int $projectId = null)
    {
        $query = ContractorRating::where('trade_id', $tradeId)
            ->with(['project', 'ratedBy']);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    /**
     * Get contractor performance summary
     */
    public function getContractorSummary(int $contractorId): array
    {
        $contractor = Contractor::with('trades.ratings')->findOrFail($contractorId);
        
        $tradeRatings = [];
        
        foreach ($contractor->trades as $trade) {
            $avgSpeed = $trade->ratings->avg('speed');
            $avgQuality = $trade->ratings->avg('quality');
            
            $tradeRatings[] = [
                'trade_id' => $trade->id,
                'trade_type' => $trade->trade_type,
                'avg_speed' => round($avgSpeed ?? 0, 1),
                'avg_quality' => round($avgQuality ?? 0, 1),
                'trade_rating' => round((($avgSpeed ?? 0) + ($avgQuality ?? 0)) / 2, 1),
                'total_ratings' => $trade->ratings->count(),
            ];
        }

        // Overall rating = average of all trade ratings
        $overallRating = 0;
        if (!empty($tradeRatings)) {
            $sumTradeRatings = array_sum(array_column($tradeRatings, 'trade_rating'));
            $overallRating = round($sumTradeRatings / count($tradeRatings), 1);
        }

        return [
            'contractor_id' => $contractor->id,
            'contractor_name' => $contractor->name,
            'overall_rating' => $overallRating,
            'trades' => $tradeRatings,
        ];
    }

    /**
     * Get all contractors with ratings for a project
     */
    public function getProjectContractorRatings(int $projectId): array
    {
        $ratings = ContractorRating::where('project_id', $projectId)
            ->with(['contractor', 'trade', 'ratedBy'])
            ->get()
            ->groupBy('contractor_id');

        $result = [];
        
        foreach ($ratings as $contractorId => $contractorRatings) {
            $contractor = $contractorRatings->first()->contractor;
            
            $trades = $contractorRatings->map(function ($rating) {
                return [
                    'trade_id' => $rating->trade_id,
                    'trade_type' => $rating->trade->trade_type,
                    'speed' => $rating->speed,
                    'quality' => $rating->quality,
                    'trade_rating' => round(($rating->speed + $rating->quality) / 2, 1),
                    'rated_by' => $rating->ratedBy->name,
                    'comments' => $rating->comments,
                ];
            })->toArray();

            $overallRating = collect($trades)->avg('trade_rating');

            $result[] = [
                'contractor_id' => $contractorId,
                'contractor_name' => $contractor->name,
                'overall_rating' => round($overallRating, 1),
                'trades' => $trades,
            ];
        }

        return $result;
    }
}
