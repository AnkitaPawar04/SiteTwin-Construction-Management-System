<?php

namespace Database\Seeders;

use App\Models\DailyProgressReport;
use App\Models\DprPhoto;
use App\Models\Approval;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class DprSeeder extends Seeder
{
    public function run()
    {
        $dprs = [
            // Approved DPRs
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Completed foundation excavation for Block A. Total excavation depth: 12 feet. Removed approximately 150 cubic meters of soil. Work completed as per structural drawings.',
                'report_date' => Carbon::today()->subDays(8),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'approved',
                'created_at' => Carbon::today()->subDays(8)->setTime(18, 30),
                'photos' => 3,
            ],
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Installed steel reinforcement for ground floor columns. Total 24 columns completed with TMT bars (16mm & 20mm). Binding done as per structural specifications.',
                'report_date' => Carbon::today()->subDays(7),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'approved',
                'created_at' => Carbon::today()->subDays(7)->setTime(18, 15),
                'photos' => 4,
            ],
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Poured M25 concrete for ground floor slab. Area covered: 500 sq ft. Used ready-mix concrete from authorized supplier. Curing process initiated.',
                'report_date' => Carbon::today()->subDays(5),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'approved',
                'created_at' => Carbon::today()->subDays(5)->setTime(17, 45),
                'photos' => 5,
            ],
            [
                'project_id' => 2,
                'user_id' => 4,
                'work_description' => 'Site clearing and ground leveling completed. Removed vegetation and debris. Leveled 2000 sq meters area. Ready for foundation marking.',
                'report_date' => Carbon::today()->subDays(6),
                'latitude' => 18.5511,
                'longitude' => 73.9450,
                'status' => 'approved',
                'created_at' => Carbon::today()->subDays(6)->setTime(18, 0),
                'photos' => 3,
            ],

            // Submitted (Pending Approval) DPRs
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Brickwork for external walls in progress. Completed 40% of ground floor perimeter wall. Used red clay bricks with cement mortar (1:6 ratio). Height achieved: 8 feet.',
                'report_date' => Carbon::today()->subDays(2),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'submitted',
                'created_at' => Carbon::today()->subDays(2)->setTime(18, 20),
                'photos' => 4,
            ],
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Electrical conduit installation for first floor. Completed living room, bedroom 1 and bedroom 2 conduits. All conduits laid as per electrical layout. Used PVC pipes (25mm).',
                'report_date' => Carbon::today()->subDays(1),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'submitted',
                'created_at' => Carbon::today()->subDays(1)->setTime(17, 50),
                'photos' => 3,
            ],
            [
                'project_id' => 2,
                'user_id' => 4,
                'work_description' => 'Foundation excavation Phase 1 - 60% completed. Excavated to 15 feet depth. Soil testing samples collected. Water seepage controlled with dewatering pump.',
                'report_date' => Carbon::today()->subDays(1),
                'latitude' => 18.5511,
                'longitude' => 73.9450,
                'status' => 'submitted',
                'created_at' => Carbon::today()->subDays(1)->setTime(18, 10),
                'photos' => 4,
            ],
            [
                'project_id' => 1,
                'user_id' => 4,
                'work_description' => 'Plumbing rough-in work for ground floor bathrooms completed. Installed drainage pipes, water supply lines. Used CPVC for hot water and PVC for cold water. All connections tested.',
                'report_date' => Carbon::today(),
                'latitude' => 19.1136,
                'longitude' => 72.8697,
                'status' => 'submitted',
                'created_at' => Carbon::today()->setTime(17, 30),
                'photos' => 3,
            ],
        ];

        foreach ($dprs as $dprData) {
            $photoCount = $dprData['photos'];
            unset($dprData['photos']);

            $dpr = DailyProgressReport::create($dprData);

            // Create photos
            for ($i = 1; $i <= $photoCount; $i++) {
                DprPhoto::create([
                    'dpr_id' => $dpr->id,
                    'photo_url' => "https://example.com/construction/project{$dpr->project_id}/dpr{$dpr->id}_photo{$i}.jpg",
                    'created_at' => $dpr->created_at,
                ]);
            }

            // Create approval record
            Approval::create([
                'reference_type' => 'dpr',
                'reference_id' => $dpr->id,
                'approved_by' => $dpr->status === 'approved' ? 3 : null,
                'status' => $dpr->status === 'approved' ? 'approved' : 'pending',
                'created_at' => $dpr->status === 'approved' ? $dpr->created_at->addHours(1) : $dpr->created_at,
            ]);
        }

        $this->command->info('Created ' . count($dprs) . ' DPRs with photos and approvals');
    }
}
