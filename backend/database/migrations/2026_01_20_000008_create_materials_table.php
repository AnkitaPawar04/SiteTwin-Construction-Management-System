<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMaterialsTable extends Migration
{
    public function up()
    {
        Schema::create('materials', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name');
            $table->string('unit')->nullable();
            $table->decimal('gst_percentage', 5, 2)->default(0);
        });
    }

    public function down()
    {
        Schema::dropIfExists('materials');
    }
}
