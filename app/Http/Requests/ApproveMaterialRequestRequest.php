<?php

namespace App\Http\Requests;

use App\Models\MaterialRequest;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ApproveMaterialRequestRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'status' => ['required', Rule::in([MaterialRequest::STATUS_APPROVED, MaterialRequest::STATUS_REJECTED])],
        ];
    }
}
