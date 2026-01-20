<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class MaterialRequestItemResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'material' => new MaterialResource($this->whenLoaded('material')),
            'quantity' => (float) $this->quantity,
        ];
    }
}
