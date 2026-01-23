<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('attendance', function (Blueprint $table) {
            $table->decimal('marked_latitude', 10, 8)->nullable()->after('status');
            $table->decimal('marked_longitude', 11, 8)->nullable()->after('marked_latitude');
            $table->integer('distance_from_geofence')->nullable()->after('marked_longitude'); // in meters
            $table->boolean('is_within_geofence')->default(true)->after('distance_from_geofence');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendance', function (Blueprint $table) {
            $table->dropColumn(['marked_latitude', 'marked_longitude', 'distance_from_geofence', 'is_within_geofence']);
        });
    }
};
