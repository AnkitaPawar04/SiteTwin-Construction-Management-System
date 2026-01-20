<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TaskResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'assigned_to' => new UserResource($this->whenLoaded('assignedToUser')),
            'assigned_by' => new UserResource($this->whenLoaded('assignedByUser')),
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'created_at' => $this->created_at?->toDateTimeString(),
        ];
    }
}
