<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceItemResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'description' => $this->description,
            'amount' => (float) $this->amount,
            'gst_percentage' => (float) $this->gst_percentage,
            'gst_amount' => (float) (($this->amount * $this->gst_percentage) / 100),
            'total' => (float) ($this->amount + (($this->amount * $this->gst_percentage) / 100)),
        ];
    }
}
