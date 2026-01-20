<?php

namespace App\Http\Requests;

use App\Models\DailyProgressReport;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ApproveDprRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'status' => ['required', Rule::in([DailyProgressReport::STATUS_APPROVED, DailyProgressReport::STATUS_REJECTED])],
        ];
    }
}
