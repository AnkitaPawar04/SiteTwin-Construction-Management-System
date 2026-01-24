<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Material;
use Illuminate\Http\Request;

class MaterialController extends Controller
{
    public function index()
    {
        $materials = Material::all();

        return response()->json([
            'success' => true,
            'data' => $materials
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'unit' => 'required|string|max:50',
            'gst_type' => 'required|in:gst,non_gst',
            'gst_percentage' => 'required_if:gst_type,gst|numeric|min:0|max:100',
        ]);

        // If non-GST, force gst_percentage to 0
        $data = $request->all();
        if ($data['gst_type'] === 'non_gst') {
            $data['gst_percentage'] = 0;
        }

        $material = Material::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Material created successfully',
            'data' => $material
        ], 201);
    }

    public function show($id)
    {
        $material = Material::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $material
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'unit' => 'sometimes|string|max:50',
            'gst_type' => 'sometimes|in:gst,non_gst',
            'gst_percentage' => 'sometimes|numeric|min:0|max:100',
        ]);

        $material = Material::findOrFail($id);
        
        $data = $request->all();
        
        // If changing to non-GST, force gst_percentage to 0
        if (isset($data['gst_type']) && $data['gst_type'] === 'non_gst') {
            $data['gst_percentage'] = 0;
        }
        
        // If changing to GST and no percentage provided, require it
        if (isset($data['gst_type']) && $data['gst_type'] === 'gst' && !isset($data['gst_percentage'])) {
            if ($material->gst_percentage == 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'GST percentage is required for GST materials'
                ], 422);
            }
        }
        
        $material->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Material updated successfully',
            'data' => $material
        ]);
    }
}
