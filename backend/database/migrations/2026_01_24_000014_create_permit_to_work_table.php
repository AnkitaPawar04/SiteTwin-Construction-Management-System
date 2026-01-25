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
        Schema::dropIfExists('permit_to_work');
        
        Schema::create('permit_to_work', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->enum('task_type', ['HEIGHT', 'ELECTRICAL', 'WELDING', 'CONFINED_SPACE', 'HOT_WORK', 'EXCAVATION'])->comment('Type of high-risk work');
            $table->text('description')->comment('Detailed description of the work to be performed');
            $table->text('safety_measures')->comment('Safety measures and equipment to be used');
            
            // Supervisor (requests permit)
            $table->foreignId('supervisor_id')->constrained('users')->onDelete('cascade');
            $table->timestamp('requested_at');
            
            // Safety officer approval
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->string('otp_code', 6)->default('123456')->comment('Fixed OTP for MVP');
            $table->timestamp('approved_at')->nullable();
            
            // Work execution
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            
            // Status
            $table->enum('status', ['PENDING', 'APPROVED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED'])->default('PENDING');
            
            // Additional details
            $table->text('notes')->nullable();
            $table->text('rejection_reason')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('permit_to_work');
    }
};
