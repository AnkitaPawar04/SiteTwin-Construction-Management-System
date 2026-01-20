<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'invoice_number' => $this->invoice_number,
            'total_amount' => (float) $this->total_amount,
            'gst_amount' => (float) $this->gst_amount,
            'status' => $this->status,
            'items' => InvoiceItemResource::collection($this->whenLoaded('items')),
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
