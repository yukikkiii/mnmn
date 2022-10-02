<?php

namespace App\Http\Controllers;

use App\Models\Contact;
use Illuminate\Http\Request;

class ContactController extends Controller
{
    public function create(Request $request)
    {
        $user = \Auth::user();
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'subject' => 'required|string',
            'body' => 'required|string|max:1000',
        ]);

        Contact::create(
            array_merge(
                $request->only('name', 'email', 'subject', 'body'),
                ['user_id' => $user->id],
            ),
        );
    }
}
