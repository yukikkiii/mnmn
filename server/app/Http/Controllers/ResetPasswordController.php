<?php

namespace App\Http\Controllers;

use App\Helpers\ValidationRules;
use Illuminate\Http\Request;
use Password;
use Validator;

class ResetPasswordController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
        ]);

        return view('reset-password');
    }

    public function reset(Request $request)
    {
        $credentials = $request->validate([
            'token' => 'required|string',
            'new_password' => ValidationRules::password(true),
        ]);

        $reset_password_status = Password::reset($credentials, function ($user, $password) {
            $user->password = $password;
            $user->save();
        });
        if ($reset_password_status === Password::INVALID_USER || $reset_password_status === Password::INVALID_TOKEN) {
            return response()
                ->view('reset-password', ['invalidToken' => true])
                ->setStatusCode(403);
        }

        return view('reset-password', ['success' => true]);
    }
}
