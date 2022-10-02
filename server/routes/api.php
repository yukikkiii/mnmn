<?php

use App\Http\Controllers\ApiAuthController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\DevController;
use App\Http\Controllers\FriendshipController;
use App\Http\Controllers\ImageUploadController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\PraySitesController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\UserLocationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('healthcheck', function (Request $request) {
    return response(['status' => true], 200);
});

Route::prefix('/v0')->group(function () {
    // Endpoints that don't require authentication
    Route::post('/auth/request-reset-password', [ApiAuthController::class, 'requestResetPassword']);
    Route::post('/auth/sign-in', [ApiAuthController::class, 'signIn']);
    Route::post('/auth/sign-up', [ApiAuthController::class, 'signUp']);

    $redirectToRoute = fn ($name) => fn () => redirect(route($name));

    // テスト用API
    if (App::isLocal()) {
        Route::post('/dev/notification', [DevController::class, 'sendNotification']);
    }

    // Endpoints that require authentication
    Route::group(['middleware' => 'auth:sanctum'], function () use ($redirectToRoute) {
        Route::post('/auth/sign-out', [ApiAuthController::class, 'signOut']);

        Route::post('/image', ImageUploadController::class);

        // User APIs
        Route::get('/users/my', [UserController::class, 'getProfile']);
        Route::post('/users/my', [UserController::class, 'updateProfile']);
        Route::post('/users/my/fcm-token', [UserController::class, 'updateFcmToken']);

        // Contact APIs
        Route::post('/contacts', [ContactController::class, 'create']);

        // Location APIs
        Route::post('/locations/update', [UserLocationController::class, 'update']);
        Route::get('/users/my/locations', [UserLocationController::class, 'index'])->name('my.locations');

        // Messaging APIs
        Route::get('/messages', [MessageController::class, 'index']);
        Route::post('/messages', [MessageController::class, 'create']);
        Route::post('/messages/retrieve', [MessageController::class, 'retrieve']);
        Route::post('/messages/{id}/open', [MessageController::class, 'open']);
        Route::post('/messages/{id}/favorite', [MessageController::class, 'favorite'])->name('messages.favorite');
        Route::post('/messages/{id}/unfavorite', [MessageController::class, 'favorite'])->name('messages.unfavorite');
        Route::get('/users/my/messages', [MessageController::class, 'listSentMessages'])->name('my.messages');
        Route::get('/users/my/unread-messages', [MessageController::class, 'unread']);

        // Friendship APIs
        Route::get('/users/my/friendships', [FriendshipController::class, 'index']);
        Route::post('/friendships', [FriendshipController::class, 'create']);
        Route::delete('/friendships', [FriendshipController::class, 'destroy']);
        Route::get('/friendships/search', [FriendshipController::class, 'search']);

        // Pray site APIs
        Route::get('/pray-sites', [PraySitesController::class, 'index']);
    });
});
