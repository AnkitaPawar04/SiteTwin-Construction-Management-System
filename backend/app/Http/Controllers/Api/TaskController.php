<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Models\Task;
use App\Services\TaskService;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    private $taskService;

    public function __construct(TaskService $taskService)
    {
        $this->taskService = $taskService;
    }

    public function index(Request $request)
    {
        if ($request->has('project_id')) {
            $tasks = $this->taskService->getTasksByProject($request->query('project_id'));
        } else {
            $tasks = $this->taskService->getUserTasks($request->user()->id);
        }

        return response()->json([
            'success' => true,
            'data' => $tasks
        ]);
    }

    public function store(StoreTaskRequest $request)
    {
        $this->authorize('create', Task::class);

        $task = $this->taskService->createTask(
            $request->project_id,
            $request->assigned_to,
            $request->user()->id,
            $request->title,
            $request->description
        );

        return response()->json([
            'success' => true,
            'message' => 'Task created successfully',
            'data' => $task
        ], 201);
    }

    public function show($id)
    {
        $task = Task::with(['project', 'assignedToUser', 'assignedByUser'])->findOrFail($id);
        $this->authorize('view', $task);

        return response()->json([
            'success' => true,
            'data' => $task
        ]);
    }

    public function update(UpdateTaskRequest $request, $id)
    {
        $task = Task::findOrFail($id);
        $this->authorize('update', $task);

        $task->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Task updated successfully',
            'data' => $task
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,in_progress,completed'
        ]);

        $task = Task::findOrFail($id);
        $this->authorize('update', $task);

        $task = $this->taskService->updateTaskStatus($id, $request->status);

        return response()->json([
            'success' => true,
            'message' => 'Task status updated successfully',
            'data' => $task
        ]);
    }

    public function destroy($id)
    {
        $task = Task::findOrFail($id);
        $this->authorize('delete', $task);

        $task->delete();

        return response()->json([
            'success' => true,
            'message' => 'Task deleted successfully'
        ]);
    }
}
