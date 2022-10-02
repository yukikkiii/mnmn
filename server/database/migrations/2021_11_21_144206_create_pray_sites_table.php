<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePraySitesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('pray_sites', function (Blueprint $table) {
            $table->id();
            $table->boolean('is_paid')->default(false);
            $table->string('name');
            $table->unsignedInteger('views')->default(0);
            $table->point('point');
            $table->string('pr')->nullable();
            $table->unsignedTinyInteger('prefecture_id')->nullable();
            $table->unsignedSmallInteger('radius')->default(100);
            $table->timestamps();

            $table->foreign('prefecture_id')->on('prefectures')->references('id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('pray_sites');
    }
}
