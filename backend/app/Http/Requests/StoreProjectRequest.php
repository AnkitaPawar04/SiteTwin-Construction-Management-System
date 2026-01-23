<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProjectRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'description' => 'nullable|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'geofence_radius_meters' => 'nullable|integer|min:10|max:5000',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'owner_id' => 'required|exists:users,id',
        ];
    }
}
