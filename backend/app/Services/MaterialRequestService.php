<?php

namespace App\Services;

use App\Models\MaterialRequest;
use App\Models\MaterialRequestItem;
use App\Models\Approval;
use App\Models\Notification;
use App\Models\Stock;
use App\Models\StockTransaction;
use Illuminate\Support\Facades\DB;

class MaterialRequestService
{
    private $stockService;

    public function __construct(StockService $stockService)
    {
        $this->stockService = $stockService;
    }

    public function createMaterialRequest($projectId, $requestedBy, array $items)
    {
        return DB::transaction(function () use ($projectId, $requestedBy, $items) {
            $request = MaterialRequest::create([
                'project_id' => $projectId,
                'requested_by' => $requestedBy,
                'status' => MaterialRequest::STATUS_PENDING,
            ]);

            foreach ($items as $item) {
                MaterialRequestItem::create([
                    'request_id' => $request->id,
                    'material_id' => $item['material_id'],
                    'quantity' => $item['quantity'],
                ]);
            }

            // Create approval record
            Approval::create([
                'reference_type' => 'material_request',
                'reference_id' => $request->id,
                'status' => Approval::STATUS_PENDING,
            ]);

            return $request->load('items.material');
        });
    }

    public function approveMaterialRequest($requestId, $approverId, $status)
    {
        return DB::transaction(function () use ($requestId, $approverId, $status) {
            $request = MaterialRequest::findOrFail($requestId);

            if ($request->status !== MaterialRequest::STATUS_PENDING) {
                throw new \Exception('Material request is not in pending status');
            }

            $request->update([
                'approved_by' => $approverId,
                'status' => $status,
            ]);

            // Update approval record
            $approval = Approval::where('reference_type', 'material_request')
                ->where('reference_id', $requestId)
                ->first();

            if ($approval) {
                $approval->update([
                    'approved_by' => $approverId,
                    'status' => $status === MaterialRequest::STATUS_APPROVED
                        ? Approval::STATUS_APPROVED
                        : Approval::STATUS_REJECTED,
                ]);
            }

            // Send notification
            Notification::create([
                'user_id' => $request->requested_by,
                'message' => "Your material request has been " . $status,
                'is_read' => false,
            ]);

            return $request->load('items.material');
        });
    }

    public function receiveMaterialRequest($requestId, array $receivedItems)
    {
        return DB::transaction(function () use ($requestId, $receivedItems) {
            $request = MaterialRequest::findOrFail($requestId);

            if ($request->status !== MaterialRequest::STATUS_APPROVED) {
                throw new \Exception('Material request must be approved before receiving it');
            }

            foreach ($request->items as $item) {
                // Check if this item's reception is reported
                $receivedQuantity = isset($receivedItems[$item->id])
                    ? $receivedItems[$item->id]
                    : (isset($receivedItems[(string) $item->id])
                        ? $receivedItems[(string) $item->id]
                        : 0);

                $receivedQuantity = intval($receivedQuantity);

                if ($receivedQuantity > 0) {
                    // This is where Stock IN happens linked to the request
                    $this->stockService->addStock(
                        $request->project_id,
                        $item->material_id,
                        $receivedQuantity,
                        $request->id
                    );
                }
            }

            $request->update(['status' => MaterialRequest::STATUS_RECEIVED]);

            return $request->load('items.material');
        });
    }

    public function updateRequestStatus($requestId, $approverId, $status, $remarks = null, $allocatedItems = [])
    {
        return DB::transaction(function () use ($requestId, $approverId, $status, $remarks, $allocatedItems) {
            $request = MaterialRequest::findOrFail($requestId);

            if ($request->status !== MaterialRequest::STATUS_PENDING) {
                throw new \Exception('Material request is not in pending status');
            }

            // Check if this is a partial approval
            $isPartialApproval = false;
            if ($status === 'approved' && !empty($allocatedItems)) {
                foreach ($request->items as $item) {
                    $quantity = isset($allocatedItems[$item->id])
                        ? $allocatedItems[$item->id]
                        : (isset($allocatedItems[(string) $item->id])
                            ? $allocatedItems[(string) $item->id]
                            : $item->quantity);

                    $quantity = intval($quantity);
                    if ($quantity < $item->quantity) {
                        $isPartialApproval = true;
                        break;
                    }
                }
            }

            // Only update status to approved/rejected if fully approved/rejected
            // For partial approval, keep status as pending
            if (!$isPartialApproval) {
                $request->update([
                    'approved_by' => $approverId,
                    'status' => $status,
                ]);
            }

            // Update approval record
            $approval = Approval::where('reference_type', 'material_request')
                ->where('reference_id', $requestId)
                ->first();

            if ($approval && !$isPartialApproval) {
                $approval->update([
                    'approved_by' => $approverId,
                    'status' => $status === 'approved'
                        ? Approval::STATUS_APPROVED
                        : Approval::STATUS_REJECTED,
                    'remarks' => $remarks,
                ]);
            }

            // Send notification
            $message = $isPartialApproval
                ? "Your material request has been partially approved. Some items are still pending."
                : "Your material request has been " . $status;
            if ($remarks) {
                $message .= ". Remarks: " . $remarks;
            }

            Notification::create([
                'user_id' => $request->requested_by,
                'type' => 'approval',
                'message' => $message,
                'is_read' => false,
            ]);

            return $request->load('items.material');
        });
    }

    public function getMaterialRequestsByProject($projectId)
    {
        return MaterialRequest::where('project_id', $projectId)
            ->with(['items.material', 'requestedBy', 'approvedBy'])
            ->orderBy('created_at', 'desc')
            ->get();
    }
}
