<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$task = \App\Models\Task::find(13);
$task->status = 'in_progress';
$task->save();
echo "Updated task 13 to in_progress\n";
