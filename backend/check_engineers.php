<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$engineers = App\Models\User::whereIn('role', ['engineer', 'site_engineer'])->get(['id', 'name', 'phone', 'role']);

echo "Engineers in database:\n";
echo "--------------------\n";
foreach ($engineers as $user) {
    echo "ID: {$user->id}, Name: {$user->name}, Phone: {$user->phone}, Role: {$user->role}\n";
}
echo "\nTotal: " . $engineers->count() . " engineers\n";
