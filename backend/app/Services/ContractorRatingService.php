<?php

namespace App\Services;

use App\Models\ContractorRating;
use App\Models\User;
use App\Models\Project;
use Illuminate\Support\Facades\DB;

class ContractorRatingService
{
    /**
     * Create or update contractor rating
     */
    public function rateContractor(array $data): ContractorRating
    {
        $rating = ContractorRating::updateOrCreate(
            [
                'contractor_id' => $data['contractor_id'],
                'project_id' => $data['project_id'],
                'rating_period_start' => $data['rating_period_start'],
            ],
            [
                'rating_period_end' => $data['rating_period_end'],
                'punctuality_score' => $data['punctuality_score'],
                'quality_score' => $data['quality_score'],
                'safety_score' => $data['safety_score'],
                'wastage_score' => $data['wastage_score'],
                'rated_by' => $data['rated_by'],
                'comments' => $data['comments'] ?? null,
            ]
        );

        // Calculate overall rating
        $overallRating = $rating->calculateOverallRating();
        
        // Determine payment action
        $paymentAction = $this->determinePaymentAction($overallRating);
        $penaltyAmount = $this->calculatePenalty($overallRating, $data['penalty_base_amount'] ?? 0);

        $rating->update([
            'overall_rating' => $overallRating,
            'payment_action' => $paymentAction,
            'penalty_amount' => $penaltyAmount,
        ]);

        return $rating->fresh();
    }

    /**
     * Get contractor performance history
     */
    public function getContractorHistory(int $contractorId, ?int $projectId = null)
    {
        $query = ContractorRating::where('contractor_id', $contractorId)
            ->with(['project', 'ratedBy']);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        return $query->orderBy('rating_period_start', 'desc')->get();
    }

    /**
     * Get contractor average rating
     */
    public function getContractorAverageRating(int $contractorId): array
    {
        $ratings = ContractorRating::where('contractor_id', $contractorId)
            ->selectRaw('
                AVG(punctuality_score) as avg_punctuality,
                AVG(quality_score) as avg_quality,
                AVG(safety_score) as avg_safety,
                AVG(wastage_score) as avg_wastage,
                AVG(overall_rating) as avg_overall,
                COUNT(*) as total_ratings
            ')
            ->first();

        return [
            'avg_punctuality' => round($ratings->avg_punctuality ?? 0, 1),
            'avg_quality' => round($ratings->avg_quality ?? 0, 1),
            'avg_safety' => round($ratings->avg_safety ?? 0, 1),
            'avg_wastage' => round($ratings->avg_wastage ?? 0, 1),
            'avg_overall' => round($ratings->avg_overall ?? 0, 1),
            'total_ratings' => $ratings->total_ratings,
        ];
    }

    /**
     * Get contractors with poor ratings (below threshold)
     */
    public function getContractorsNeedingAttention(float $threshold = 5.0): array
    {
        return ContractorRating::where('overall_rating', '<', $threshold)
            ->with(['contractor', 'project'])
            ->orderBy('overall_rating', 'asc')
            ->get()
            ->toArray();
    }

    /**
     * Determine payment action based on rating
     */
    private function determinePaymentAction(float $rating): string
    {
        if ($rating < 4.0) {
            return 'PENALTY';
        } elseif ($rating < 5.0) {
            return 'HOLD';
        }
        return 'NORMAL';
    }

    /**
     * Calculate penalty amount
     */
    private function calculatePenalty(float $rating, float $baseAmount): ?float
    {
        if ($rating >= 4.0) {
            return null;
        }

        // Penalty percentage increases as rating decreases
        $penaltyPercentage = (4.0 - $rating) * 10; // 10% per rating point below 4
        
        return round($baseAmount * ($penaltyPercentage / 100), 2);
    }
}
