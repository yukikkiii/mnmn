<?php

namespace Database\Seeders\Dev;

use App\Models\PraySite;
use App\Models\Prefecture;
use Grimzy\LaravelMysqlSpatial\Types\Point;
use Illuminate\Database\Seeder;

class PraySiteSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $count = PraySite::count();
        if ($count === 0) {
            $this
                ->praySite('東京タワー', '東京', 35.658584, 139.7454316)
                ->save();
            $this
                ->praySite('富士山頂', '山梨', 35.3625, 138.7306)
                ->save();
        }
    }

    private function praySite(string $name, string $prefName, float $lat, float $long)
    {
        $prefCode = Prefecture::where('name', $prefName)
            ->first()
            ->id;

        $site = new PraySite(['name' => $name]);
        $site->point = new Point($lat, $long);
        $site->prefecture_id = $prefCode;
        return $site;
    }
}
