<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateMessagesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->point('location')->nullable()->change();
            $table->unsignedBigInteger('pray_site_id')->nullable();

            $table->foreign('pray_site_id')->on('pray_sites')->references('id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->point('location')->nullable(false)->change();

            $table->dropForeign('messages_pray_site_id_foreign');
            $table->dropColumn('pray_site_id');
        });
    }
}
