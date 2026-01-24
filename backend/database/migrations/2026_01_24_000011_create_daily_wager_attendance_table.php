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
        Schema::dropIfExists('daily_wager_attendance');
        
        Schema::create('daily_wager_attendance', function (Blueprint $table) {
            $table->id();
            $table->string('wager_name');
            $table->string('wager_phone')->nullable();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->date('attendance_date');
            $table->time('check_in_time')->nullable();
            $table->time('check_out_time')->nullable();
            
            // Face recognition data
            $table->string('face_image_path')->nullable();
            $table->string('face_encoding')->nullable(); // For ML matching
            
            // Wage calculation
            $table->decimal('hours_worked', 5, 2)->default(0);
            $table->decimal('wage_rate_per_hour', 8, 2)->default(0);
            $table->decimal('total_wage', 10, 2)->default(0);
            
            // Verification
            $table->foreignId('verified_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('verified_at')->nullable();
            $table->enum('status', ['PENDING', 'VERIFIED', 'REJECTED'])->default('PENDING');
            
            $table->timestamps();
            
            // Unique attendance per wager per day per project
            $table->unique(['wager_name', 'project_id', 'attendance_date'], 'unique_wager_attendance');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('daily_wager_attendance');
    }
};
