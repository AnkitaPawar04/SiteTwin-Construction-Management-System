<?php

namespace App\Http\Requests;

use App\Models\StockTransaction;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreStockTransactionRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'project_id' => 'required|exists:projects,id',
            'material_id' => 'required|exists:materials,id',
            'quantity' => 'required|numeric|min:0.01',
            'type' => ['required', Rule::in([StockTransaction::TYPE_IN, StockTransaction::TYPE_OUT])],
            'reference_id' => 'nullable|integer',
        ];
    }
}
