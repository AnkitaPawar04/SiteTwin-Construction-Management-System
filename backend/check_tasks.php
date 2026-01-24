<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$tasks = \App\Models\Task::whereNotNull('billing_amount')->get(['id', 'title', 'status', 'billing_amount', 'gst_percentage']);
echo "Tasks with billing:\n";
foreach ($tasks as $t) {
    echo "  ID: {$t->id}, Status: {$t->status}, Title: {$t->title}, Amount: ₹{$t->billing_amount} + {$t->gst_percentage}%\n";
}
