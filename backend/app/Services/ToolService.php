<?php

namespace App\Services;

use App\Models\Tool;
use App\Models\ToolCheckout;
use Carbon\Carbon;
use Illuminate\Support\Str;

class ToolService
{
    /**
     * Add new tool to library
     */
    public function addTool(array $data): Tool
    {
        $tool = Tool::create([
            'tool_name' => $data['tool_name'],
            'tool_code' => $data['tool_code'] ?? $this->generateToolCode($data['tool_name']),
            'qr_code' => $data['qr_code'] ?? Str::uuid(),
            'category' => $data['category'],
            'purchase_date' => $data['purchase_date'] ?? null,
            'purchase_price' => $data['purchase_price'] ?? null,
            'condition' => $data['condition'] ?? 'EXCELLENT',
            'description' => $data['description'] ?? null,
            'current_status' => 'AVAILABLE',
        ]);

        return $tool;
    }

    /**
     * Checkout tool
     */
    public function checkoutTool(array $data): ToolCheckout
    {
        $tool = Tool::findOrFail($data['tool_id']);

        if (!$tool->isAvailable()) {
            throw new \Exception("Tool is not available. Current status: {$tool->current_status}");
        }

        $checkout = ToolCheckout::create([
            'tool_id' => $data['tool_id'],
            'checked_out_by' => $data['checked_out_by'],
            'project_id' => $data['project_id'],
            'checkout_time' => Carbon::now(),
            'expected_return_time' => $data['expected_return_time'],
            'checkout_notes' => $data['checkout_notes'] ?? null,
            'status' => 'ACTIVE',
        ]);

        // Update tool status
        $tool->update([
            'current_status' => 'CHECKED_OUT',
            'current_holder_id' => $data['checked_out_by'],
            'current_project_id' => $data['project_id'],
        ]);

        return $checkout->load(['tool', 'checkedOutBy', 'project']);
    }

    /**
     * Return tool
     */
    public function returnTool(int $checkoutId, array $data): ToolCheckout
    {
        $checkout = ToolCheckout::with('tool')->findOrFail($checkoutId);

        if ($checkout->status !== 'ACTIVE') {
            throw new \Exception("This checkout is not active. Current status: {$checkout->status}");
        }

        $returnTime = Carbon::now();
        $status = $returnTime->isAfter($checkout->expected_return_time) ? 'OVERDUE' : 'RETURNED';

        $checkout->update([
            'actual_return_time' => $returnTime,
            'return_condition' => $data['return_condition'],
            'verified_by' => $data['verified_by'],
            'return_notes' => $data['return_notes'] ?? null,
            'status' => 'RETURNED',
        ]);

        // Update tool status
        $newToolStatus = 'AVAILABLE';
        if (in_array($data['return_condition'], ['POOR', 'DAMAGED'])) {
            $newToolStatus = 'MAINTENANCE';
        }

        $checkout->tool->update([
            'current_status' => $newToolStatus,
            'current_holder_id' => null,
            'current_project_id' => null,
            'condition' => $data['return_condition'],
        ]);

        return $checkout->fresh(['tool', 'checkedOutBy', 'verifiedBy']);
    }

    /**
     * Get overdue tools
     */
    public function getOverdueTools(?int $projectId = null): array
    {
        $query = ToolCheckout::where('status', 'ACTIVE')
            ->where('expected_return_time', '<', Carbon::now())
            ->with(['tool', 'checkedOutBy', 'project']);

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        $overdueCheckouts = $query->get();

        return $overdueCheckouts->map(function ($checkout) {
            return [
                'checkout_id' => $checkout->id,
                'tool_name' => $checkout->tool->tool_name,
                'tool_code' => $checkout->tool->tool_code,
                'checked_out_by' => $checkout->checkedOutBy->name,
                'project_name' => $checkout->project->name,
                'expected_return_time' => $checkout->expected_return_time,
                'days_overdue' => $checkout->getDaysOverdue(),
            ];
        })->toArray();
    }

    /**
     * Get tool availability report
     */
    public function getAvailabilityReport(): array
    {
        $tools = Tool::all();

        return [
            'total_tools' => $tools->count(),
            'available' => $tools->where('current_status', 'AVAILABLE')->count(),
            'checked_out' => $tools->where('current_status', 'CHECKED_OUT')->count(),
            'maintenance' => $tools->where('current_status', 'MAINTENANCE')->count(),
            'damaged' => $tools->where('current_status', 'DAMAGED')->count(),
            'lost' => $tools->where('current_status', 'LOST')->count(),
            'by_category' => $tools->groupBy('category')->map->count(),
        ];
    }

    /**
     * Get tool usage history
     */
    public function getToolHistory(int $toolId): array
    {
        $tool = Tool::with(['checkouts.checkedOutBy', 'checkouts.project'])->findOrFail($toolId);

        $checkouts = $tool->checkouts()->orderBy('checkout_time', 'desc')->get();

        return [
            'tool' => $tool,
            'total_checkouts' => $checkouts->count(),
            'total_overdue_returns' => $checkouts->filter->isOverdue()->count(),
            'checkout_history' => $checkouts,
        ];
    }

    /**
     * Mark tool as lost
     */
    public function markAsLost(int $checkoutId): void
    {
        $checkout = ToolCheckout::with('tool')->findOrFail($checkoutId);

        $checkout->update(['status' => 'LOST']);
        $checkout->tool->update(['current_status' => 'LOST']);
    }

    /**
     * Generate unique tool code
     */
    private function generateToolCode(string $toolName): string
    {
        $prefix = strtoupper(substr($toolName, 0, 3));
        $number = Tool::where('tool_code', 'like', $prefix . '%')->count() + 1;
        
        return $prefix . '-' . str_pad($number, 4, '0', STR_PAD_LEFT);
    }
}
