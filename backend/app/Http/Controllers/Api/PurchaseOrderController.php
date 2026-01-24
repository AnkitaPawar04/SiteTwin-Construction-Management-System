<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PurchaseOrder;
use App\Models\MaterialRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PurchaseOrderController extends Controller
{
    /**
     * Get all purchase orders
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', PurchaseOrder::class);
        $query = PurchaseOrder::with(['project', 'vendor', 'materialRequest', 'items.material', 'createdBy']);

        // Filter by project if specified
        if ($request->has('project_id')) {
            $query->where('project_id', $request->project_id);
        }

        // Filter by status if specified
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $purchaseOrders = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $purchaseOrders
        ]);
    }

    /**
     * Get single purchase order details
     */
    public function show($id)
    {
        $purchaseOrder = PurchaseOrder::with([
            'project',
            'vendor',
            'materialRequest.items.material',
            'items.material',
            'createdBy'
        ])->findOrFail($id);

        $this->authorize('view', $purchaseOrder);

        return response()->json([
            'success' => true,
            'data' => $purchaseOrder
        ]);
    }

    /**
     * Create new purchase order
     */
    public function store(Request $request)
    {
        $this->authorize('create', PurchaseOrder::class);

        $validated = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'vendor_id' => 'required|exists:vendors,id',
            'material_request_id' => 'nullable|exists:material_requests,id',
            'type' => 'required|in:gst,non_gst',
            'items' => 'required|array|min:1',
            'items.*.material_id' => 'required|exists:materials,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.unit' => 'required|string',
            'items.*.rate' => 'required|numeric|min:0',
            'items.*.gst_percentage' => 'nullable|numeric|min:0|max:100',
        ]);

        try {
            DB::beginTransaction();

            $poNumber = PurchaseOrder::generatePONumber();
            
            // Calculate totals
            $totalAmount = 0;
            $totalGstAmount = 0;

            foreach ($validated['items'] as $item) {
                $amount = $item['quantity'] * $item['rate'];
                $gstPercentage = $item['gst_percentage'] ?? 0;
                $gstAmount = ($amount * $gstPercentage) / 100;
                
                $totalAmount += $amount;
                $totalGstAmount += $gstAmount;
            }

            $grandTotal = $totalAmount + $totalGstAmount;

            // Create purchase order
            $purchaseOrder = PurchaseOrder::create([
                'po_number' => $poNumber,
                'project_id' => $validated['project_id'],
                'vendor_id' => $validated['vendor_id'],
                'material_request_id' => $validated['material_request_id'] ?? null,
                'created_by' => auth()->id(),
                'status' => PurchaseOrder::STATUS_CREATED,
                'type' => $validated['type'],
                'total_amount' => $totalAmount,
                'gst_amount' => $totalGstAmount,
                'grand_total' => $grandTotal,
            ]);

            // Create purchase order items
            foreach ($validated['items'] as $item) {
                $amount = $item['quantity'] * $item['rate'];
                $gstPercentage = $item['gst_percentage'] ?? 0;
                $gstAmount = ($amount * $gstPercentage) / 100;
                $totalItemAmount = $amount + $gstAmount;

                $purchaseOrder->items()->create([
                    'material_id' => $item['material_id'],
                    'quantity' => $item['quantity'],
                    'unit' => $item['unit'],
                    'rate' => $item['rate'],
                    'amount' => $amount,
                    'gst_percentage' => $gstPercentage,
                    'gst_amount' => $gstAmount,
                    'total_amount' => $totalItemAmount,
                ]);
            }

            // Update material request status if linked
            if ($validated['material_request_id']) {
                $materialRequest = MaterialRequest::find($validated['material_request_id']);
                if ($materialRequest && $materialRequest->status === MaterialRequest::STATUS_REVIEWED) {
                    // Keep status as reviewed, PO created doesn't mean approved yet
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Purchase Order created successfully',
                'data' => $purchaseOrder->load(['project', 'vendor', 'items.material'])
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create purchase order: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Update purchase order status
     */
    public function updateStatus(Request $request, $id)
    {
        $purchaseOrder = PurchaseOrder::findOrFail($id);
        $this->authorize('updateStatus', $purchaseOrder);

        $validated = $request->validate([
            'status' => 'required|in:created,approved,delivered,closed',
        ]);

        try {
            $purchaseOrder = PurchaseOrder::findOrFail($id);
            
            $purchaseOrder->status = $validated['status'];
            
            // Set timestamps based on status
            if ($validated['status'] === PurchaseOrder::STATUS_APPROVED) {
                $purchaseOrder->approved_at = now();
            } elseif ($validated['status'] === PurchaseOrder::STATUS_DELIVERED) {
                $purchaseOrder->delivered_at = now();
            } elseif ($validated['status'] === PurchaseOrder::STATUS_CLOSED) {
                $purchaseOrder->closed_at = now();
            }
            
            $purchaseOrder->save();

            return response()->json([
                'success' => true,
                'message' => 'Purchase Order status updated successfully',
                'data' => $purchaseOrder
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update status: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Upload vendor invoice
     */
    public function uploadInvoice(Request $request, $id)
    {
        $purchaseOrder = PurchaseOrder::findOrFail($id);
        $this->authorize('uploadInvoice', $purchaseOrder);

        $validated = $request->validate([
            'invoice' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120', // 5MB max
        ]);

        try {
            $purchaseOrder = PurchaseOrder::findOrFail($id);

            // Delete old invoice if exists
            if ($purchaseOrder->invoice_file) {
                Storage::disk('public')->delete($purchaseOrder->invoice_file);
            }

            // Store new invoice
            $path = $request->file('invoice')->store('purchase_orders/invoices', 'public');
            
            $purchaseOrder->invoice_file = $path;
            $purchaseOrder->save();

            return response()->json([
                'success' => true,
                'message' => 'Invoice uploaded successfully',
                'data' => $purchaseOrder
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload invoice: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Delete purchase order
     */
    public function destroy($id)
    {
        $purchaseOrder = PurchaseOrder::findOrFail($id);
        $this->authorize('delete', $purchaseOrder);

        try {
            
            // Only allow deletion of created status POs
            if ($purchaseOrder->status !== PurchaseOrder::STATUS_CREATED) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete purchase order with status: ' . $purchaseOrder->status
                ], 422);
            }

            // Delete invoice file if exists
            if ($purchaseOrder->invoice_file) {
                Storage::disk('public')->delete($purchaseOrder->invoice_file);
            }

            $purchaseOrder->delete();

            return response()->json([
                'success' => true,
                'message' => 'Purchase Order deleted successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete purchase order: ' . $e->getMessage()
            ], 422);
        }
    }
}
