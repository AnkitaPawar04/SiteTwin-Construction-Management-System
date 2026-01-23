<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChangeMaterialRequestItemsQuantityToInteger extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('material_request_items', function (Blueprint $table) {
            // Change quantity from decimal(12,4) to integer
            $table->integer('quantity')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('material_request_items', function (Blueprint $table) {
            // Revert to decimal(12,4)
            $table->decimal('quantity', 12, 4)->change();
        });
    }
}
