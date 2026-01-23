<?php
require 'bootstrap/app.php';

$dprs = App\Models\DailyProgressReport::with('photos')->get();
echo "Total DPRs: " . $dprs->count() . "\n";

foreach ($dprs as $dpr) {
    echo "DPR ID: {$dpr->id}, Status: {$dpr->status}, Photos: {$dpr->photos->count()}\n";
    foreach ($dpr->photos as $photo) {
        echo "  - Photo {$photo->id}: {$photo->photo_url}\n";
    }
}
