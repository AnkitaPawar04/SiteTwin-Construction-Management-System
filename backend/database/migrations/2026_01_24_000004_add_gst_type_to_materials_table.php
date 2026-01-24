<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddGstTypeToMaterialsTable extends Migration
{
    public function up()
    {
        Schema::table('materials', function (Blueprint $table) {
            $table->string('gst_type')->default('gst')->after('unit'); // 'gst' or 'non_gst'
        });
    }

    public function down()
    {
        Schema::table('materials', function (Blueprint $table) {
            $table->dropColumn('gst_type');
        });
    }
}
