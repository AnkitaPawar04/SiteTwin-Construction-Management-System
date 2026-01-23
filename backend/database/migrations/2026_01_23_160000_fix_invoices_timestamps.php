<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // First, update existing records to have created_at if null
        DB::table('invoices')
            ->whereNull('created_at')
            ->update(['created_at' => DB::raw('NOW()')]);

        // Then modify the table structure
        Schema::table('invoices', function (Blueprint $table) {
            // Make created_at not nullable with default
            $table->timestamp('created_at')->nullable(false)->default(DB::raw('CURRENT_TIMESTAMP'))->change();
            // Add updated_at
            $table->timestamp('updated_at')->nullable()->after('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->timestamp('created_at')->nullable()->change();
            $table->dropColumn('updated_at');
        });
    }
};
