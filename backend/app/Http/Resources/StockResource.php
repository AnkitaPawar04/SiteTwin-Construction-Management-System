<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class StockResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'material' => new MaterialResource($this->whenLoaded('material')),
            'available_quantity' => (float) $this->available_quantity,
            'updated_at' => $this->updated_at?->toDateTimeString(),
        ];
    }
}
