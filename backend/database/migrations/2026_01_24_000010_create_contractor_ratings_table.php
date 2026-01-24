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
        Schema::dropIfExists('contractor_ratings');
        
        Schema::create('contractor_ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('contractor_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->date('rating_period_start');
            $table->date('rating_period_end');
            
            // Individual metrics (0-10)
            $table->decimal('punctuality_score', 3, 1)->default(0);
            $table->decimal('quality_score', 3, 1)->default(0);
            $table->decimal('safety_score', 3, 1)->default(0);
            $table->decimal('wastage_score', 3, 1)->default(0);
            
            // Calculated overall rating (0-10)
            $table->decimal('overall_rating', 3, 1)->default(0);
            
            // Actions
            $table->enum('payment_action', ['NORMAL', 'HOLD', 'PENALTY'])->default('NORMAL');
            $table->decimal('penalty_amount', 10, 2)->nullable();
            
            // Metadata
            $table->foreignId('rated_by')->constrained('users')->onDelete('cascade');
            $table->text('comments')->nullable();
            $table->timestamps();
            
            // Ensure one rating per contractor per project per period
            $table->unique(['contractor_id', 'project_id', 'rating_period_start']);
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
