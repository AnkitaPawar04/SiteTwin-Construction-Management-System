<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Create pivot table for DPR-Task many-to-many relationship
        Schema::create('dpr_tasks', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('dpr_id');
            $table->unsignedBigInteger('task_id');
            $table->timestamps();
            
            $table->foreign('dpr_id')->references('id')->on('daily_progress_reports')->onDelete('cascade');
            $table->foreign('task_id')->references('id')->on('tasks')->onDelete('cascade');
            
            // Prevent duplicate task assignments to same DPR
            $table->unique(['dpr_id', 'task_id']);
        });

        // Migrate existing task_id from daily_progress_reports to dpr_tasks
        DB::statement("
            INSERT INTO dpr_tasks (dpr_id, task_id, created_at, updated_at)
            SELECT id, task_id, NOW(), NOW()
            FROM daily_progress_reports
            WHERE task_id IS NOT NULL
        ");

        // Remove task_id column from daily_progress_reports as we now use pivot table
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            $table->dropForeign(['task_id']);
            $table->dropColumn('task_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Add task_id back to daily_progress_reports
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            $table->unsignedBigInteger('task_id')->nullable()->after('project_id');
            $table->foreign('task_id')->references('id')->on('tasks')->onDelete('set null');
        });

        // Migrate first task from pivot table back to task_id
        DB::statement("
            UPDATE daily_progress_reports dpr
            SET task_id = (
                SELECT task_id 
                FROM dpr_tasks 
                WHERE dpr_id = dpr.id 
                LIMIT 1
            )
        ");

        // Drop pivot table
        Schema::dropIfExists('dpr_tasks');
    }
};
