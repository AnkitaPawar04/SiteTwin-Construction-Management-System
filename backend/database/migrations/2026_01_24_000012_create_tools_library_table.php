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
        Schema::dropIfExists('tools_library');
        
        Schema::create('tools_library', function (Blueprint $table) {
            $table->id();
            $table->string('tool_name');
            $table->string('tool_code')->unique();
            $table->string('qr_code')->unique();
            $table->string('category'); // Electrical, Carpentry, Safety, etc.
            
            // Status tracking
            $table->enum('current_status', ['AVAILABLE', 'CHECKED_OUT', 'MAINTENANCE', 'DAMAGED', 'LOST'])->default('AVAILABLE');
            $table->foreignId('current_holder_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('current_project_id')->nullable()->constrained('projects')->onDelete('set null');
            
            // Tool details
            $table->date('purchase_date')->nullable();
            $table->decimal('purchase_price', 10, 2)->nullable();
            $table->enum('condition', ['EXCELLENT', 'GOOD', 'FAIR', 'POOR'])->default('EXCELLENT');
            $table->text('description')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tools_library');
    }
};
