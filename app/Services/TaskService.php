<?php

namespace App\Services;

use App\Models\Task;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;

class TaskService
{
    public function createTask($projectId, $assignedTo, $assignedBy, $title, $description)
    {
        return DB::transaction(function () use ($projectId, $assignedTo, $assignedBy, $title, $description) {
            $task = Task::create([
                'project_id' => $projectId,
                'assigned_to' => $assignedTo,
                'assigned_by' => $assignedBy,
                'title' => $title,
                'description' => $description,
                'status' => Task::STATUS_PENDING,
            ]);

            // Send notification to assigned user
            Notification::create([
                'user_id' => $assignedTo,
                'message' => "New task assigned: {$title}",
                'is_read' => false,
            ]);

            return $task;
        });
    }

    public function updateTaskStatus($taskId, $status)
    {
        $task = Task::findOrFail($taskId);
        $task->update(['status' => $status]);
        return $task;
    }

    public function getTasksByProject($projectId)
    {
        return Task::where('project_id', $projectId)
            ->with(['assignedToUser', 'assignedByUser'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getUserTasks($userId)
    {
        return Task::where('assigned_to', $userId)
            ->with(['project', 'assignedByUser'])
            ->orderBy('created_at', 'desc')
            ->get();
    }
}
