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
            $table->string('task_description');
            $table->enum('risk_level', ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])->default('MEDIUM');
            
            // Request details
            $table->foreignId('requested_by')->constrained('users')->onDelete('cascade');
            $table->timestamp('requested_at');
            
            // Safety officer approval
            $table->foreignId('safety_officer_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('otp_code', 6)->nullable();
            $table->timestamp('otp_generated_at')->nullable();
            $table->timestamp('otp_expires_at')->nullable();
            $table->timestamp('approved_at')->nullable();
            
            // Work execution
            $table->timestamp('work_started_at')->nullable();
            $table->timestamp('work_completed_at')->nullable();
            $table->foreignId('completed_by')->nullable()->constrained('users')->onDelete('set null');
            
            // Status
            $table->enum('status', ['PENDING', 'OTP_SENT', 'APPROVED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'EXPIRED'])->default('PENDING');
            
            // Additional details
            $table->text('safety_measures')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->text('completion_notes')->nullable();
            
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
