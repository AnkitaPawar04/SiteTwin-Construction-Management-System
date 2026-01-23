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
            // Worker (user_id: 4) notifications
            ['user_id' => 4, 'message' => 'New task assigned: Foundation excavation - Block A', 'is_read' => true, 'created_at' => Carbon::now()->subDays(8)],
            ['user_id' => 4, 'message' => 'Your DPR for ' . Carbon::today()->subDays(8)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(7)],
            ['user_id' => 4, 'message' => 'New task assigned: Steel reinforcement - Ground floor columns', 'is_read' => true, 'created_at' => Carbon::now()->subDays(7)],
            ['user_id' => 4, 'message' => 'Your DPR for ' . Carbon::today()->subDays(7)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(6)],
            ['user_id' => 4, 'message' => 'Your material request has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(9)],
            ['user_id' => 4, 'message' => 'Material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(2)],
            
            // Engineer (user_id: 3) notifications
            ['user_id' => 3, 'message' => 'New task assigned: Concrete pouring - Ground floor slab', 'is_read' => true, 'created_at' => Carbon::now()->subDays(5)],
            ['user_id' => 3, 'message' => 'Your DPR for ' . Carbon::today()->subDays(5)->format('d M Y') . ' has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(4)],
            ['user_id' => 3, 'message' => 'Your material request has been approved', 'is_read' => true, 'created_at' => Carbon::now()->subDays(6)],
            ['user_id' => 3, 'message' => 'Material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(1)],
            ['user_id' => 3, 'message' => '1 material request pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(2)],
            
            // Manager (user_id: 2) notifications
            ['user_id' => 2, 'message' => '4 DPRs pending your approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(5)],
            ['user_id' => 2, 'message' => '2 material requests pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subHours(3)],
            ['user_id' => 2, 'message' => 'New task assigned: Brickwork - External walls', 'is_read' => true, 'created_at' => Carbon::now()->subDays(4)],
            ['user_id' => 2, 'message' => 'Your DPR is pending approval', 'is_read' => false, 'created_at' => Carbon::now()->subDays(1)],
            
            // Owner (user_id: 1) notifications
            ['user_id' => 1, 'message' => 'Project Commercial Plaza - Andheri: 60% tasks completed', 'is_read' => true, 'created_at' => Carbon::now()->subDays(1)],
            ['user_id' => 1, 'message' => 'Invoice INV-20260120-0004 generated for ₹4,43,700', 'is_read' => false, 'created_at' => Carbon::now()->subHours(6)],
            ['user_id' => 1, 'message' => 'Stock alert: Cement running low in Project 1', 'is_read' => false, 'created_at' => Carbon::now()->subHours(12)],
        ];

        foreach ($notifications as $notification) {
            Notification::create($notification);
        }

        $this->command->info('Created ' . count($notifications) . ' notifications');
    }
}
