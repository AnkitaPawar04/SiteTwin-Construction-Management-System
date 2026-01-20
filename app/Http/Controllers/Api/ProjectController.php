<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProjectRequest;
use App\Http\Requests\UpdateProjectRequest;
use App\Models\Project;
use App\Models\ProjectUser;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->isOwner()) {
            $projects = Project::where('owner_id', $user->id)->get();
        } else {
            $projects = $user->projects;
        }

        return response()->json([
            'success' => true,
            'data' => $projects
        ]);
    }

    public function store(StoreProjectRequest $request)
    {
        $this->authorize('create', Project::class);

        $project = Project::create($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Project created successfully',
            'data' => $project
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $project = Project::with(['owner', 'users'])->findOrFail($id);
        $this->authorize('view', $project);

        return response()->json([
            'success' => true,
            'data' => $project
        ]);
    }

    public function update(UpdateProjectRequest $request, $id)
    {
        $project = Project::findOrFail($id);
        $this->authorize('update', $project);

        $project->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Project updated successfully',
            'data' => $project
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $project = Project::findOrFail($id);
        $this->authorize('delete', $project);

        $project->delete();

        return response()->json([
            'success' => true,
            'message' => 'Project deleted successfully'
        ]);
    }

    public function assignUser(Request $request, $id)
    {
        $project = Project::findOrFail($id);
        $this->authorize('update', $project);

        $request->validate([
            'user_id' => 'required|exists:users,id'
        ]);

        $existing = ProjectUser::where('project_id', $id)
            ->where('user_id', $request->user_id)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'User already assigned to this project'
            ], 422);
        }

        ProjectUser::create([
            'project_id' => $id,
            'user_id' => $request->user_id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User assigned to project successfully'
        ]);
    }

    public function removeUser(Request $request, $id, $userId)
    {
        $project = Project::findOrFail($id);
        $this->authorize('update', $project);

        ProjectUser::where('project_id', $id)
            ->where('user_id', $userId)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'User removed from project successfully'
        ]);
    }
}
