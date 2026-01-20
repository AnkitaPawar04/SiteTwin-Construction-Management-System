<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class AttendanceResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'user' => new UserResource($this->whenLoaded('user')),
            'project' => new ProjectResource($this->whenLoaded('project')),
            'date' => $this->date?->toDateString(),
            'check_in' => $this->check_in?->toDateTimeString(),
            'check_out' => $this->check_out?->toDateTimeString(),
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'is_verified' => $this->is_verified,
        ];
    }
}
