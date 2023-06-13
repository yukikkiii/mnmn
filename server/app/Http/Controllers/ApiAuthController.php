<?php

namespace App\Http\Controllers;

use App\Helpers\ValidationRules;
use App\Models\User;
use Arr;
use Hash;
use Illuminate\Http\Request;
use Password;
use Validator;

class ApiAuthController extends Controller
{
    public function requestResetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $credentials = $request->only('email');
        $sendResetLinkResult = Password::sendResetLink($credentials);
        $success = $sendResetLinkResult === Password::RESET_LINK_SENT;

        \Log::info("Sending password reset link to {$credentials['email']}: " . json_encode($success));

        // Always return success regardless of actual result
        return [
            'success' => true,
        ];
    }

    public function signIn(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required',
        ]);
        $user = User::where('email', $request->email)->first();
        if (!$user || !Hash::check($request->password, $user->password)) {
            abort(401);
        }

        return [
            'token' => $user->createToken($request->device_name)->plainTextToken,
        ];
    }

    public function signUp(Request $request)
    {
        $input = $request->all();
        $validator = Validator::make($input, [
            'name' => 'required|unique:users,name',
            'device_name' => 'required',
            'email' => 'unique:users|required',
            'password' => ValidationRules::password(),
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors(),
            ];
        }
        $merge = array_merge(
            Arr::only($input, ['name', 'email']),
            [
                'password' => Hash::make($input['password'])
            ],
        );

        $user = User::create($merge);

        $token = $user->createToken($input['device_name'])->plainTextToken;
        return [
            'success' => true,
            'token' => $token,
        ];
    }

    public function signOut(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return [
            'success' => true,
        ];
    }
}
