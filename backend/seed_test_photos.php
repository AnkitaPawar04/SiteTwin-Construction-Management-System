<?php
require 'bootstrap/app.php';

// Create test DPR with photos for DPR ID 11
$dpr = \App\Models\DailyProgressReport::findOrFail(11);

// Create fake photo records that point to placeholder images
$photos = [
    [
        'dpr_id' => 11,
        'photo_url' => 'dprs/project_1/dpr_11/test_photo_1.jpg'
    ],
    [
        'dpr_id' => 11,
        'photo_url' => 'dprs/project_1/dpr_11/test_photo_2.jpg'
    ]
];

foreach ($photos as $photo) {
    try {
        \App\Models\DprPhoto::create($photo);
        echo "Created photo record: " . $photo['photo_url'] . "\n";
    } catch (\Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
}

echo "Done!\n";
