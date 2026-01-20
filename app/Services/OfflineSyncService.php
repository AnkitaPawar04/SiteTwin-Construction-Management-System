<?php

namespace App\Services;

use App\Models\OfflineSyncLog;
use Illuminate\Support\Facades\DB;

class OfflineSyncService
{
    public function logSyncAction($userId, $entity, $entityId, $action)
    {
        return OfflineSyncLog::create([
            'user_id' => $userId,
            'entity' => $entity,
            'entity_id' => $entityId,
            'action' => $action,
            'synced' => false,
        ]);
    }

    public function markAsSynced($logId)
    {
        $log = OfflineSyncLog::findOrFail($logId);
        $log->update(['synced' => true]);
        return $log;
    }

    public function getPendingSyncLogs($userId)
    {
        return OfflineSyncLog::where('user_id', $userId)
            ->where('synced', false)
            ->orderBy('created_at', 'asc')
            ->get();
    }

    public function syncBatch(array $records)
    {
        return DB::transaction(function () use ($records) {
            $synced = [];
            
            foreach ($records as $record) {
                // Process each record based on entity type
                // This is where you would handle conflict resolution
                
                $synced[] = $this->logSyncAction(
                    $record['user_id'],
                    $record['entity'],
                    $record['entity_id'],
                    $record['action']
                );
            }

            return $synced;
        });
    }
}
