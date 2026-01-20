<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDprPhotosTable extends Migration
{
    public function up()
    {
        Schema::create('dpr_photos', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('dpr_id');
            $table->string('photo_url')->nullable();
            $table->timestamp('created_at')->nullable();

            $table->foreign('dpr_id')->references('id')->on('daily_progress_reports')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('dpr_photos');
    }
}
