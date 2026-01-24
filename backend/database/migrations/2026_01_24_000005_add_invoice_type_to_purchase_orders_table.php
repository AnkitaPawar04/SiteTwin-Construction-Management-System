<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddInvoiceTypeToPurchaseOrdersTable extends Migration
{
    public function up()
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->string('invoice_type')->nullable()->after('invoice_file'); // 'gst' or 'non_gst'
        });
    }

    public function down()
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->dropColumn('invoice_type');
        });
    }
}
