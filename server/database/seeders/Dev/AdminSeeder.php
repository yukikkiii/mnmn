<?php

namespace Database\Seeders\Dev;

use App\Models\Admin;
use Hash;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Admin::insertOrIgnore([
            'name' => 'admin',
            'email' => "admin@localhost",
            'password' => Hash::make("password"),
        ]);
    }
}
