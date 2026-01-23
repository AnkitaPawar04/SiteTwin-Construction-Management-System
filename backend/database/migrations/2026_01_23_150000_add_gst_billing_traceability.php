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
        // Add task_id and dpr_id to invoices table for traceability
        Schema::table('invoices', function (Blueprint $table) {
            $table->unsignedBigInteger('task_id')->nullable()->after('project_id');
            $table->unsignedBigInteger('dpr_id')->nullable()->after('task_id');
            
            $table->foreign('task_id')->references('id')->on('tasks')->onDelete('set null');
            $table->foreign('dpr_id')->references('id')->on('daily_progress_reports')->onDelete('set null');
        });

        // Add task_id to invoice_items for detailed traceability
        Schema::table('invoice_items', function (Blueprint $table) {
            $table->unsignedBigInteger('task_id')->nullable()->after('invoice_id');
            
            $table->foreign('task_id')->references('id')->on('tasks')->onDelete('set null');
        });

        // task_id already exists in daily_progress_reports table, just add foreign key if not exists
        if (!Schema::hasColumn('daily_progress_reports', 'task_id')) {
            Schema::table('daily_progress_reports', function (Blueprint $table) {
                $table->unsignedBigInteger('task_id')->nullable()->after('project_id');
            });
        }
        
        // Add foreign key constraint if it doesn't exist
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            try {
                $table->foreign('task_id')->references('id')->on('tasks')->onDelete('set null');
            } catch (\Exception $e) {
                // Foreign key might already exist, ignore
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_progress_reports', function (Blueprint $table) {
            $table->dropForeign(['task_id']);
            $table->dropColumn('task_id');
        });

        Schema::table('invoice_items', function (Blueprint $table) {
            $table->dropForeign(['task_id']);
            $table->dropColumn('task_id');
        });

        Schema::table('invoices', function (Blueprint $table) {
            $table->dropForeign(['task_id']);
            $table->dropForeign(['dpr_id']);
            $table->dropColumn(['task_id', 'dpr_id']);
        });
    }
};
