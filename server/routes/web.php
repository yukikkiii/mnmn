<?php

use App\Http\Controllers\ResetPasswordController;
use App\Http\Controllers\UpdateEmailController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\URL;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

$proxy_url    = getenv('PROXY_URL');
$proxy_schema = getenv('PROXY_SCHEMA');

if (!empty($proxy_url)) {
   URL::forceRootUrl($proxy_url);
}
if (!empty($proxy_schema)) {
   URL::forceScheme($proxy_schema);
}

Route::get('/', function () {
    return view('welcome');
});

Route::get('/reset-password', [ResetPasswordController::class, 'index'])->name('password.reset');
Route::post('/reset-password', [ResetPasswordController::class, 'reset']);

Route::get('/update-email', UpdateEmailController::class)->name('email.update');
