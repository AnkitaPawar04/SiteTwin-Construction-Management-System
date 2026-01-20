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
            'gst_percentage' => 'required|numeric|min:0|max:100',
        ]);

        $material = Material::create($request->all());

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
            'gst_percentage' => 'sometimes|numeric|min:0|max:100',
        ]);

        $material = Material::findOrFail($id);
        $material->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Material updated successfully',
            'data' => $material
        ]);
    }
}
