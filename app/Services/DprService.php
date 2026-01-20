<?php

namespace App\Services;

use App\Models\DailyProgressReport;
use App\Models\DprPhoto;
use App\Models\Approval;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DprService
{
    public function createDpr($userId, $projectId, $workDescription, $latitude, $longitude, $photos = [])
    {
        return DB::transaction(function () use ($userId, $projectId, $workDescription, $latitude, $longitude, $photos) {
            $dpr = DailyProgressReport::create([
                'user_id' => $userId,
                'project_id' => $projectId,
                'work_description' => $workDescription,
                'report_date' => Carbon::today()->toDateString(),
                'latitude' => $latitude,
                'longitude' => $longitude,
                'status' => DailyProgressReport::STATUS_SUBMITTED,
            ]);

            // Add photos
            if (!empty($photos)) {
                foreach ($photos as $photoUrl) {
                    DprPhoto::create([
                        'dpr_id' => $dpr->id,
                        'photo_url' => $photoUrl,
                    ]);
                }
            }

            // Create approval record
            Approval::create([
                'reference_type' => 'dpr',
                'reference_id' => $dpr->id,
                'status' => Approval::STATUS_PENDING,
            ]);

            return $dpr->load('photos');
        });
    }

    public function approveDpr($dprId, $approverId, $status)
    {
        return DB::transaction(function () use ($dprId, $approverId, $status) {
            $dpr = DailyProgressReport::findOrFail($dprId);

            if ($dpr->status !== DailyProgressReport::STATUS_SUBMITTED) {
                throw new \Exception('DPR is not in submitted status');
            }

            $dpr->update(['status' => $status]);

            // Update approval record
            $approval = Approval::where('reference_type', 'dpr')
                ->where('reference_id', $dprId)
                ->first();

            if ($approval) {
                $approval->update([
                    'approved_by' => $approverId,
                    'status' => $status === DailyProgressReport::STATUS_APPROVED 
                        ? Approval::STATUS_APPROVED 
                        : Approval::STATUS_REJECTED,
                ]);
            }

            // Send notification to DPR creator
            Notification::create([
                'user_id' => $dpr->user_id,
                'message' => "Your DPR for " . $dpr->report_date->format('d M Y') . " has been " . $status,
                'is_read' => false,
            ]);

            return $dpr;
        });
    }

    public function getDprsByProject($projectId, $startDate = null, $endDate = null)
    {
        $query = DailyProgressReport::where('project_id', $projectId)
            ->with(['user', 'photos']);

        if ($startDate) {
            $query->where('report_date', '>=', $startDate);
        }

        if ($endDate) {
            $query->where('report_date', '<=', $endDate);
        }

        return $query->orderBy('report_date', 'desc')->get();
    }
}
