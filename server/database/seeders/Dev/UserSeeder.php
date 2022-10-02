<?php

namespace Database\Seeders\Dev;

use DB;
use Hash;
use Illuminate\Database\Seeder;
use Str;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        foreach (range(1, 4) as $i) {
            DB::table('users')->insertOrIgnore([
                'name' => Str::random(10),
                'email' => "dev$i@example.com",
                'password' => Hash::make("password$i"),
            ]);
        }
    }
}
