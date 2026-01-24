<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    /**
     * Get all vendors
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Vendor::class);

        $query = Vendor::query();

        // Filter active vendors
        if ($request->has('active')) {
            $query->where('is_active', $request->boolean('active'));
        }

        $vendors = $query->orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data' => $vendors
        ]);
    }

    /**
     * Get single vendor
     */
    public function show($id)
    {
        $vendor = Vendor::with('purchaseOrders')->findOrFail($id);
        $this->authorize('view', $vendor);

        return response()->json([
            'success' => true,
            'data' => $vendor
        ]);
    }

    /**
     * Create new vendor
     */
    public function store(Request $request)
    {
        $this->authorize('create', Vendor::class);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'gst_number' => 'nullable|string|max:15',
            'address' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $vendor = Vendor::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Vendor created successfully',
            'data' => $vendor
        ], 201);
    }

    /**
     * Update vendor
     */
    public function update(Request $request, $id)
    {
        $vendor = Vendor::findOrFail($id);
        $this->authorize('update', $vendor);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'gst_number' => 'nullable|string|max:15',
            'address' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $vendor->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Vendor updated successfully',
            'data' => $vendor
        ]);
    }

    /**
     * Delete vendor
     */
    public function destroy($id)
    {
        $vendor = Vendor::findOrFail($id);
        $this->authorize('delete', $vendor);

        try {
            
            // Check if vendor has purchase orders
            if ($vendor->purchaseOrders()->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete vendor with existing purchase orders'
                ], 422);
            }

            $vendor->delete();

            return response()->json([
                'success' => true,
                'message' => 'Vendor deleted successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete vendor: ' . $e->getMessage()
            ], 422);
        }
    }
}
