<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreDprRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'project_id' => 'required|exists:projects,id',
            'work_description' => 'required|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'photos' => 'nullable|array',
            'photos.*' => 'required|file|image|mimes:jpeg,png,jpg|max:5120', // Max 5MB
        ];
    }
}
