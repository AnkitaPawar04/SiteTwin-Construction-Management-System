<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePurchaseOrderItemsTable extends Migration
{
    public function up()
    {
        Schema::create('purchase_order_items', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('purchase_order_id');
            $table->unsignedBigInteger('material_id');
            $table->decimal('quantity', 10, 2);
            $table->string('unit');
            $table->decimal('rate', 10, 2);
            $table->decimal('amount', 12, 2);
            $table->decimal('gst_percentage', 5, 2)->default(0);
            $table->decimal('gst_amount', 12, 2)->default(0);
            $table->decimal('total_amount', 12, 2);

            $table->foreign('purchase_order_id')->references('id')->on('purchase_orders')->onDelete('cascade');
            $table->foreign('material_id')->references('id')->on('materials')->onDelete('restrict');
        });
    }

    public function down()
    {
        Schema::dropIfExists('purchase_order_items');
    }
}
