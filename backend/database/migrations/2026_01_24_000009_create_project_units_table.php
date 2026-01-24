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
        Schema::create('project_units', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            
            // Unit details
            $table->string('unit_number', 50); // e.g., "A-101", "Tower B - 12th Floor - Flat 3"
            $table->string('unit_type', 50); // e.g., "1BHK", "2BHK", "3BHK", "Commercial Shop"
            $table->decimal('floor_area', 10, 2); // Square feet or square meters
            $table->string('floor_area_unit', 20)->default('sqft'); // sqft or sqm
            
            // Sale status
            $table->boolean('is_sold')->default(false);
            $table->decimal('sold_price', 12, 2)->nullable();
            $table->date('sold_date')->nullable();
            $table->string('buyer_name', 255)->nullable();
            
            // Cost allocation (calculated from total project cost)
            $table->decimal('allocated_cost', 12, 2)->nullable();
            
            // Additional metadata
            $table->text('description')->nullable();
            
            $table->timestamps();
            
            // Unique constraint: one unit number per project
            $table->unique(['project_id', 'unit_number']);
            
            // Indexes
            $table->index('project_id');
            $table->index('is_sold');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('project_units');
    }
};
