<?php

namespace Database\Seeders\Dev;

use App;
use Illuminate\Database\Seeder;

class DevDatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $seeders = [
            UserSeeder::class,
            PraySiteSeeder::class,
        ];
        // if (App::isLocal()) {
        array_push($seeders, AdminSeeder::class);
        // }

        $this->call($seeders);
    }
}
