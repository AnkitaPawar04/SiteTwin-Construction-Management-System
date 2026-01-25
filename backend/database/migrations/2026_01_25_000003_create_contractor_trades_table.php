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
        Schema::create('contractor_trades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('contractor_id')->constrained('contractors')->onDelete('cascade');
            $table->enum('trade_type', [
                'Plumbing',
                'Electrical',
                'Tiling',
                'Painting',
                'Carpentry',
                'Masonry',
                'Plastering',
                'Waterproofing',
                'Flooring',
                'Roofing',
                'HVAC',
                'Other'
            ]);
            $table->timestamps();
            
            // Ensure one trade type per contractor
            $table->unique(['contractor_id', 'trade_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contractor_trades');
    }
};
