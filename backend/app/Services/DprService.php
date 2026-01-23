<?php

namespace App\Services;

use App\Models\DailyProgressReport;
use App\Models\DprPhoto;
use App\Models\Approval;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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

            // Add photos - store files and save paths
            if (!empty($photos)) {
                foreach ($photos as $photo) {
                    // Generate unique filename with proper naming convention
                    $fileName = $this->generatePhotoFileName($dpr->id, $photo);
                    
                    // Store the file in public disk (accessible via HTTP)
                    $path = $photo->store("dprs/project_{$projectId}/dpr_{$dpr->id}", 'public');
                    
                    // Save the file path to database
                    DprPhoto::create([
                        'dpr_id' => $dpr->id,
                        'photo_url' => $path,
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

    /**
     * Generate a proper naming convention for photos
     * Format: dpr_{dpr_id}_{timestamp}_{random}.{extension}
     */
    private function generatePhotoFileName($dprId, $photoFile)
    {
        $timestamp = time();
        $random = mt_rand(1000, 9999);
        $extension = $photoFile->getClientOriginalExtension();
        
        return "dpr_{$dprId}_{$timestamp}_{$random}.{$extension}";
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

    public function updateDprStatus($dprId, $approverId, $status, $remarks = null)
    {
        return DB::transaction(function () use ($dprId, $approverId, $status, $remarks) {
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
                    'status' => $status === 'approved' 
                        ? Approval::STATUS_APPROVED 
                        : Approval::STATUS_REJECTED,
                    'remarks' => $remarks,
                ]);
            }

            // Send notification to DPR creator
            $message = "Your DPR for " . $dpr->report_date->format('d M Y') . " has been " . $status;
            if ($remarks) {
                $message .= ". Remarks: " . $remarks;
            }

            Notification::create([
                'user_id' => $dpr->user_id,
                'type' => 'approval',
                'message' => $message,
                'is_read' => false,
            ]);

            return $dpr->load('photos');
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
