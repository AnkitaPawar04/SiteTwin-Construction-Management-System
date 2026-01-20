<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\OfflineSyncService;
use Illuminate\Http\Request;

class OfflineSyncController extends Controller
{
    private $offlineSyncService;

    public function __construct(OfflineSyncService $offlineSyncService)
    {
        $this->offlineSyncService = $offlineSyncService;
    }

    public function pendingLogs(Request $request)
    {
        $logs = $this->offlineSyncService->getPendingSyncLogs($request->user()->id);

        return response()->json([
            'success' => true,
            'data' => $logs
        ]);
    }

    public function syncBatch(Request $request)
    {
        $request->validate([
            'records' => 'required|array',
            'records.*.entity' => 'required|string',
            'records.*.entity_id' => 'required|integer',
            'records.*.action' => 'required|string',
        ]);

        try {
            $synced = $this->offlineSyncService->syncBatch($request->records);

            return response()->json([
                'success' => true,
                'message' => 'Batch synced successfully',
                'data' => $synced
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function markAsSynced(Request $request, $id)
    {
        try {
            $log = $this->offlineSyncService->markAsSynced($id);

            return response()->json([
                'success' => true,
                'message' => 'Log marked as synced',
                'data' => $log
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }
}
