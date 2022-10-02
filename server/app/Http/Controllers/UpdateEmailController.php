<?php

namespace App\Http\Controllers;

use App\Models\EmailUpdateRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UpdateEmailController extends Controller
{
    public function __invoke(Request $request)
    {
        /** @var EmailUpdateRequest */
        $updateRequest = EmailUpdateRequest::where('token', $request->query('token'))
            ->firstOrFail();

        DB::transaction(function () use ($updateRequest) {
            $user = User::findOrFail($updateRequest->user_id);
            $user->update([
                'email' => $updateRequest->new_email,
            ]);
            $updateRequest->delete();
        });

        return view('update-email-complete');
    }
}
