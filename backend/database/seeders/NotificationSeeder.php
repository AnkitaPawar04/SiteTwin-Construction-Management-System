<?php

namespace Database\Seeders;

use App\Models\Notification;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class NotificationSeeder extends Seeder
{
    public function run()
    {
        $notifications = [
            // Worker notifications
            ['user_id' => 7, 'message' => 'New task assigned: Foundation excavation - Block A', 'is_read' => true, 'created_at' => Carbon::now()->subDays(8)],
            ['user_id' => 7, 'message' => 'Your DPR for ' . Carbon::today()->subDays(8)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(7)],
            
            ['user_id' => 8, 'message' => 'New task assigned: Steel reinforcement - Ground floor columns', 'is_read' => true, 'created_at' => Carbon::now()->subDays(7)],
            ['user_id' => 8, 'message' => 'Your DPR for ' . Carbon::today()->subDays(7)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(6)],
            
            ['user_id' => 9, 'message' => 'New task assigned: Concrete pouring - Ground floor slab', 'is_read' => true, 'created_at' => Carbon::now()->subDays(5)],
            ['user_id' => 9, 'message' => 'Your DPR for ' . Carbon::today()->subDays(5)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(4)],
            
            ['user_id' => 10, 'message' => 'New task assigned: Brickwork - External walls', 'is_read' => true, 'created_at' => Carbon::now()->subDays(4)],
            ['user_id' => 10, 'message' => 'Your DPR is pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(1)],
            
            ['user_id' => 11, 'message' => 'New task assigned: Electrical conduit installation - First floor', 'is_read' => false, 'created_at' => Carbon::now()->subDays(2)],
            ['user_id' => 11, 'message' => 'Your DPR is pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(4)],
            
            ['user_id' => 12, 'message' => 'New task assigned: Plumbing rough-in - Ground floor', 'is_read' => false, 'created_at' => Carbon::now()->subDays(1)],
            ['user_id' => 12, 'message' => 'Your DPR for today has been submitted successfully', 'is_read' => false, 'created_at' => Carbon::now()->subHours(1)],
            
            ['user_id' => 13, 'message' => 'New task assigned: Plastering - Interior walls', 'is_read' => false, 'created_at' => Carbon::now()->subHours(3)],
            
            // Engineer notifications
            ['user_id' => 4, 'message' => 'Your material request has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(9)],
            ['user_id' => 4, 'message' => 'Material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(2)],
            
            ['user_id' => 5, 'message' => 'Your material request has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(6)],
            ['user_id' => 5, 'message' => 'Material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(1)],
            
            ['user_id' => 6, 'message' => 'Your material request has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(7)],
            ['user_id' => 6, 'message' => 'Material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(2)],
            
            // Manager notifications
            ['user_id' => 2, 'message' => '4 DPRs pending your approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(5)],
            ['user_id' => 2, 'message' => '2 material requests pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(3)],
            
            ['user_id' => 3, 'message' => '1 material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(2)],
            
            // Owner notifications
            ['user_id' => 1, 'message' => 'Project Commercial Plaza - Andheri: 60% tasks completed', 'is_read' => true, 'created_at' => Carbon::now()->subDays(1)],
            ['user_id' => 1, 'message' => 'Invoice INV-20260120-0004 generated for ₹4,43,700', 'is_read' => false, 'created_at' => Carbon::now()->subHours(6)],
            ['user_id' => 1, 'message' => 'Stock alert: Cement running low in Project 1', 'is_read' => false, 'created_at' => Carbon::now()->subHours(12)],
            
            // Project 2 workers
            ['user_id' => 17, 'message' => 'New task assigned: Site preparation and leveling', 'is_read' => true, 'created_at' => Carbon::now()->subDays(6)],
            ['user_id' => 17, 'message' => 'Your DPR for ' . Carbon::today()->subDays(6)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(5)],
            
            ['user_id' => 19, 'message' => 'New task assigned: Foundation excavation - Phase 1', 'is_read' => true, 'created_at' => Carbon::now()->subDays(3)],
            ['user_id' => 19, 'message' => 'Your DPR is pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(8)],
        ];

        foreach ($notifications as $notification) {
            Notification::create($notification);
        }

        $this->command->info('Created ' . count($notifications) . ' notifications');
    }
}
