<?php

namespace Database\Seeders;

use App\Models\Attendance;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class AttendanceSeeder extends Seeder
{
    public function run()
    {
        // Generate attendance for last 10 days for all project users (Manager, Engineer, Worker)
        $projectUsers = [2, 3, 4]; // Manager (2), Engineer (3), Worker (4)
        $startDate = Carbon::today()->subDays(10);
        
        for ($day = 0; $day < 10; $day++) {
            $date = $startDate->copy()->addDays($day);
            
            // Skip Sundays
            if ($date->dayOfWeek === 0) {
                continue;
            }
            
            foreach ($projectUsers as $userId) {
                // 90% attendance rate
                if (rand(1, 10) <= 9) {
                    $checkIn = $date->copy()->setTime(rand(8, 9), rand(0, 59));
                    $checkOut = $date->copy()->setTime(rand(17, 18), rand(0, 59));
                    
                    Attendance::create([
                        'user_id' => $userId,
                        'project_id' => 1,
                        'date' => $date->toDateString(),
                        'check_in' => $checkIn,
                        'check_out' => $checkOut,
                        'latitude' => 19.1136 + (rand(-10, 10) / 10000),
                        'longitude' => 72.8697 + (rand(-10, 10) / 10000),
                        'is_verified' => true,
                    ]);
                }
            }
        }

        // Generate attendance for last 5 days for Project 2
        $startDate2 = Carbon::today()->subDays(5);
        
        for ($day = 0; $day < 5; $day++) {
            $date = $startDate2->copy()->addDays($day);
            
            if ($date->dayOfWeek === 0) {
                continue;
            }
            
            foreach ($projectUsers as $userId) {
                if (rand(1, 10) <= 9) {
                    $checkIn = $date->copy()->setTime(rand(8, 9), rand(0, 59));
                    $checkOut = $date->copy()->setTime(rand(17, 18), rand(0, 59));
                    
                    Attendance::create([
                        'user_id' => $userId,
                        'project_id' => 2,
                        'date' => $date->toDateString(),
                        'check_in' => $checkIn,
                        'check_out' => $checkOut,
                        'latitude' => 18.5511 + (rand(-10, 10) / 10000),
                        'longitude' => 73.9450 + (rand(-10, 10) / 10000),
                        'is_verified' => true,
                    ]);
                }
            }
        }

        $totalAttendance = Attendance::count();
        $this->command->info("Created {$totalAttendance} attendance records");
    }
}
