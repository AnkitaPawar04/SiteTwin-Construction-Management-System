<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'message' => $this->message,
            'is_read' => $this->is_read,
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
