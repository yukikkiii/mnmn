<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTables extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // 都道府県
        Schema::create('prefectures', function (Blueprint $table) {
            $table->unsignedTinyInteger('id')->primary();
            $table->string('name', 4);
        });

        $prefs_raw = '北海道 青森 岩手 宮城 秋田 山形 福島 茨城 栃木 群馬 埼玉 千葉 東京 神奈川 新潟 富山 石川 福井 山梨 長野 岐阜 静岡 愛知 三重 滋賀 京都 大阪 兵庫 奈良 和歌山 鳥取 島根 岡山 広島 山口 徳島 香川 愛媛 高知 福岡 佐賀 長崎 熊本 大分 宮崎 鹿児島 沖縄';
        $prefs = collect(explode(' ', $prefs_raw))
            ->map(fn ($pref_name, $pref_id) => ['id' => $pref_id + 1, 'name' => $pref_name])
            ->toArray();
        DB::table('prefectures')->insert($prefs);

        // イノリドコロ
        Schema::create('places', function (Blueprint $table) {
            $table->unsignedTinyInteger('prefecture_id');

            $table->foreign('prefecture_id')->on('prefectures')->references('id');
        });

        // ユーザの位置情報履歴
        Schema::create('user_locations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->point('point');
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrentOnUpdate();

            $table->foreign('user_id')->on('users')->references('id');
        });

        // メッセージ
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->json('data');
            $table->string('text')->nullable();
            $table->unsignedTinyInteger('status');
            $table->unsignedBigInteger('from');
            $table->unsignedBigInteger('to')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrentOnUpdate();
            $table->unsignedBigInteger('user_location_id');
            $table->softDeletes();

            $table->foreign('from')->on('users')->references('id');
            $table->foreign('to')->on('users')->references('id');
            $table->foreign('user_location_id')->on('user_locations')->references('id');
        });

        // コトダマパラメータ
        Schema::create('kotodama_parameters', function (Blueprint $table) {
            $table->unsignedBigInteger('message_id')->primary();
            $emotions = [
                ['anger', '怒り'],
                ['disgust', '嫌悪'],
                ['anxiety', '不安'],
                ['joy', '喜び'],
                ['sadness', '悲しみ'],
            ];
            foreach ($emotions as $emotion) {
                $table->double($emotion[0], null, null, true)->comment($emotion[1]);
            }

            $table->foreign('message_id')->on('messages')->references('id');
        });

        Schema::create('user_messages', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('message_id');
            $table->primary(['user_id', 'message_id']);

            $table->foreign('message_id')->on('messages')->references('id');
            $table->foreign('user_id')->on('users')->references('id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('messages');
    }
}
