<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class DprPhotoResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'photo_url' => $this->photo_url,
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
