<?php

namespace App\Http\Controllers;

use App\Jobs\SendEmailUpdateMail;
use App\Jobs\UpdateEmailJob;
use Hash;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function getProfile(Request $request)
    {
        $user = \Auth::user();
        $user->makeVisible('email');

        return [
            'user' => $user,
        ];
    }

    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);
        $user = \Auth::user();

        $user->update([
            'fcm_token' => $request->input('fcm_token'),
        ]);
        return [
            'success' => true,
        ];
    }

    public function blockUser(int $id)
    {
        $user = \Auth::user();
        $block_users = $user->block_users;
        $block_users = explode(',', $block_users);
        array_push($block_users, $id);
        $block_users = implode(",", $block_users);

        $user->update([
            'block_users' => $block_users,
        ]);

        return [
            'success' => true,
        ];
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'profile_image' => 'string',
            'self_introduction' => 'string',
            'email' => 'nullable|email',
        ]);
        $user = \Auth::user();
        if ($user->name !== $request->input('name')) {
            $request->validate([
                'name' => 'unique:users,name',
            ]);
        }

        $updates = $request->only('name', 'profile_image', 'self_introduction');
        $passwordUpdate = $request->only('old_password', 'new_password');
        if (!empty($passwordUpdate)) {
            if (!Hash::check($passwordUpdate['old_password'], $user->password)) {
                return response()->json(
                    ['error' => ['code' => 'incorrect_password']],
                    401,
                );
            }

            $updates['password'] = Hash::make($passwordUpdate['new_password']);
        }
        if ($request->input('email')) {
            UpdateEmailJob::dispatchAfterResponse($user, $request->input('email'));
        }

        $user->update($updates);
        $user->makeVisible('email');

        return [
            'success' => true,
            'user' => $user,
        ];
    }
}
