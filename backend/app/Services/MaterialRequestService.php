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

    public function approveMaterialRequest($requestId, $approverId, $status, $allocatedItems = [])
    {
        return DB::transaction(function () use ($requestId, $approverId, $status, $allocatedItems) {
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

            // If approved, update stock with allocated quantities
            if ($status === MaterialRequest::STATUS_APPROVED) {
                foreach ($request->items as $item) {
                    $quantity = isset($allocatedItems[$item->id]) 
                        ? $allocatedItems[$item->id] 
                        : $item->quantity;
                    
                    if ($quantity > 0) {
                        $this->stockService->addStock(
                            $request->project_id,
                            $item->material_id,
                            $quantity,
                            $request->id
                        );
                    }
                }
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

    public function updateRequestStatus($requestId, $approverId, $status, $remarks = null, $allocatedItems = [])
    {
        return DB::transaction(function () use ($requestId, $approverId, $status, $remarks, $allocatedItems) {
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
                    'status' => $status === 'approved' 
                        ? Approval::STATUS_APPROVED 
                        : Approval::STATUS_REJECTED,
                    'remarks' => $remarks,
                ]);
            }

            // If approved, update stock with allocated quantities
            if ($status === 'approved') {
                foreach ($request->items as $item) {
                    // Check for both numeric and string keys due to JSON encoding
                    $quantity = isset($allocatedItems[$item->id]) 
                        ? $allocatedItems[$item->id] 
                        : (isset($allocatedItems[(string)$item->id]) 
                            ? $allocatedItems[(string)$item->id] 
                            : $item->quantity);
                    
                    // Ensure quantity is numeric
                    $quantity = floatval($quantity);
                    
                    if ($quantity > 0) {
                        $this->stockService->addStock(
                            $request->project_id,
                            $item->material_id,
                            $quantity,
                            $request->id
                        );
                    }
                }
            }

            // Send notification
            $message = "Your material request has been " . $status;
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
