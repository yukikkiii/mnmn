<?php

namespace App\Http\Controllers;

use App\Helpers\Utils;
use App\Models\User;
use Illuminate\Http\Request;

class DevController extends Controller
{
    public function sendNotification(Request $request)
    {
        $toUser = User::findOrFail($request->input('to'));
        $success = Utils::sendNotification(
            $request->input('title'),
            $request->input('body'),
            $toUser,
        );

        return [
            'success' => $success,
        ];
    }
}
