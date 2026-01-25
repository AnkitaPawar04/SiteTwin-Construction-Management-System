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
        // Drop the old table
        Schema::dropIfExists('contractor_ratings');
        
        // Create new table with correct structure per design
        Schema::create('contractor_ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('contractor_id')->constrained('contractors')->onDelete('cascade');
            $table->foreignId('trade_id')->constrained('contractor_trades')->onDelete('cascade');
            $table->foreignId('project_id')->constrained('projects')->onDelete('cascade');
            
            // Only 2 metrics: Speed and Quality (1-10)
            $table->decimal('speed', 3, 1)->comment('Speed rating 1-10');
            $table->decimal('quality', 3, 1)->comment('Quality rating 1-10');
            
            // Metadata
            $table->foreignId('rated_by')->constrained('users')->onDelete('cascade');
            $table->text('comments')->nullable();
            $table->timestamps();
            
            // Ensure one rating per trade per project
            $table->unique(['trade_id', 'project_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contractor_ratings');
    }
};
