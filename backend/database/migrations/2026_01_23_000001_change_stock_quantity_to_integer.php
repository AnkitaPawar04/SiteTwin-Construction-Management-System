<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChangeStockQuantityToInteger extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('stock', function (Blueprint $table) {
            // Change available_quantity from decimal(14,4) to integer
            $table->integer('available_quantity')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('stock', function (Blueprint $table) {
            // Revert to decimal(14,4)
            $table->decimal('available_quantity', 14, 4)->change();
        });
    }
}
