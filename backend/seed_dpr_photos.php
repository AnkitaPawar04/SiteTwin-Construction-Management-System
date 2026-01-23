<?php
require 'bootstrap/app.php';

// Check if DPR 11 exists
$dpr = \App\Models\DailyProgressReport::find(11);

if (!$dpr) {
    // Create a test DPR
    $dpr = \App\Models\DailyProgressReport::create([
        'project_id' => 1,
        'user_id' => 1,
        'work_description' => 'Test DPR for photo viewing',
        'report_date' => now(),
        'latitude' => 0,
        'longitude' => 0,
        'status' => 'submitted'
    ]);
    echo "Created DPR ID: " . $dpr->id . "\n";
} else {
    echo "DPR 11 already exists\n";
}

// Add photos to DPR 11
$photos = [
    ['photo_url' => 'dprs/project_1/dpr_11/test_photo_1.jpg'],
    ['photo_url' => 'dprs/project_1/dpr_11/test_photo_2.jpg']
];

foreach ($photos as $photoData) {
    try {
        $photo = \App\Models\DprPhoto::where('dpr_id', 11)
            ->where('photo_url', $photoData['photo_url'])
            ->first();
        
        if (!$photo) {
            $dpr->photos()->create($photoData);
            echo "Created photo: " . $photoData['photo_url'] . "\n";
        } else {
            echo "Photo already exists: " . $photoData['photo_url'] . "\n";
        }
    } catch (\Exception $e) {
        echo "Error creating photo: " . $e->getMessage() . "\n";
    }
}

echo "\nDPR 11 now has " . $dpr->photos()->count() . " photos\n";
