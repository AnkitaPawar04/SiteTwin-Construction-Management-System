<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProjectResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'location' => $this->location,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'owner' => new UserResource($this->whenLoaded('owner')),
            'users' => UserResource::collection($this->whenLoaded('users')),
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
