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
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            $table->decimal('billing_amount', 15, 2)->nullable();
            $table->decimal('gst_percentage', 5, 2)->default(18.00);
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->decimal('billing_amount', 15, 2)->nullable();
            $table->decimal('gst_percentage', 5, 2)->default(18.00);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            $table->dropColumn(['billing_amount', 'gst_percentage']);
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->dropColumn(['billing_amount', 'gst_percentage']);
        });
    }
};
