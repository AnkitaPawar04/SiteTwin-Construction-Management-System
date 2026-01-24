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
        Schema::dropIfExists('tool_checkouts');
        
        Schema::create('tool_checkouts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tool_id')->constrained('tools_library')->onDelete('cascade');
            $table->foreignId('checked_out_by')->constrained('users')->onDelete('cascade');
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            
            // Checkout details
            $table->timestamp('checkout_time');
            $table->timestamp('expected_return_time');
            $table->timestamp('actual_return_time')->nullable();
            
            // Return details
            $table->enum('return_condition', ['EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'DAMAGED'])->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->onDelete('set null');
            $table->text('checkout_notes')->nullable();
            $table->text('return_notes')->nullable();
            
            // Status
            $table->enum('status', ['ACTIVE', 'RETURNED', 'OVERDUE', 'LOST'])->default('ACTIVE');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tool_checkouts');
    }
};
