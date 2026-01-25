<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddMaterialFieldsToInvoiceItems extends Migration
{
    /**
     * Run the migrations - Add material-related fields for PO invoices
     */
    public function up()
    {
        Schema::table('invoice_items', function (Blueprint $table) {
            $table->unsignedBigInteger('material_id')->nullable()->after('invoice_id');
            $table->decimal('quantity', 10, 2)->nullable()->after('material_id');
            $table->string('unit')->nullable()->after('quantity');
            $table->decimal('rate', 10, 2)->nullable()->after('unit');
            $table->decimal('gst_amount', 18, 4)->nullable()->after('gst_percentage');
            $table->decimal('total_amount', 18, 4)->nullable()->after('gst_amount');
            
            $table->foreign('material_id')->references('id')->on('materials')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations
     */
    public function down()
    {
        Schema::table('invoice_items', function (Blueprint $table) {
            $table->dropForeign(['material_id']);
            $table->dropColumn(['material_id', 'quantity', 'unit', 'rate', 'gst_amount', 'total_amount']);
        });
    }
}
