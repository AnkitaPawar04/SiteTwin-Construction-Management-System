<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class RemoveTypeFromPurchaseOrders extends Migration
{
    /**
     * Run the migrations - Enable mixed GST & Non-GST items in single PO
     */
    public function up()
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->dropColumn(['type', 'invoice_type']);
        });
    }

    /**
     * Reverse the migrations
     */
    public function down()
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->string('type')->default('gst')->after('status');
            $table->string('invoice_type')->nullable()->after('invoice_file');
        });
    }
}
