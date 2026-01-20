<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMaterialRequestItemsTable extends Migration
{
    public function up()
    {
        Schema::create('material_request_items', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('request_id');
            $table->unsignedBigInteger('material_id');
            $table->decimal('quantity', 12, 4)->default(0);

            $table->foreign('request_id')->references('id')->on('material_requests')->onDelete('cascade');
            $table->foreign('material_id')->references('id')->on('materials')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('material_request_items');
    }
}
