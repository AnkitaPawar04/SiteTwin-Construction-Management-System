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
        Schema::create('material_consumption_standards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->foreignId('material_id')->constrained()->onDelete('restrict');
            
            // BOQ/Standard consumption quantity
            $table->decimal('standard_quantity', 10, 2);
            $table->string('unit', 50);
            
            // Variance tolerance (percentage) - e.g., 10 means 10% variance allowed
            $table->decimal('variance_tolerance_percentage', 5, 2)->default(10.00);
            
            // Description/notes for this standard
            $table->text('description')->nullable();
            
            $table->timestamps();
            
            // Unique constraint: one standard per material per project
            $table->unique(['project_id', 'material_id']);
            
            // Indexes for performance
            $table->index('project_id');
            $table->index('material_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('material_consumption_standards');
    }
};
