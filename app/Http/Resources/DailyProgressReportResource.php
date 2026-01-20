<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class DailyProgressReportResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'user' => new UserResource($this->whenLoaded('user')),
            'work_description' => $this->work_description,
            'report_date' => $this->report_date?->toDateString(),
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'status' => $this->status,
            'photos' => DprPhotoResource::collection($this->whenLoaded('photos')),
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
