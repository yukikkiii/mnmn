<?php

namespace App\Http\Controllers;

use App\Helpers\Utils;
use App\Models\Friendship;
use App\Models\User;
use Arr;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FriendshipController extends Controller
{
    /**
     * List all friends.
     */
    public function index(Request $request)
    {
        $user = \Auth::user();

        $query = Friendship::with('user')
            ->join('users', 'users.id', 'friendships.to')
            ->where('from', $user->id);

        $input = $request->all('name');
        if ($input['name']) {
            $query->where('users.name', 'LIKE', '%' . Utils::escapeLike($input['name']) . '%');
        }

        $friends = $query->orderByDesc('friendships.created_at')
            ->get();
        return [
            'items' => $friends,
        ];
    }

    /**
     * Add a friend.
     */
    public function create(Request $request)
    {
        $user = \Auth::user();
        $request->validate([
            'user_id' => 'required_without:user',
            'user.name' => 'required_without:user_id|string|unique:users,name',
            'user.profile_image' => 'string',
        ]);

        $success = false;

        $userId = $request->input('user_id');
        $userIds = $userId ? (is_array($userId) ? $userId : [$userId]) : null;
        if (!empty($userIds)) {
            try {
                DB::transaction(function () use ($user, $userIds) {
                    foreach ($userIds as $id) {
                        Friendship::create([
                            'from' => $user->id,
                            'to' => $id,
                        ]);
                    }
                });
            } catch (\Exception $e) {
                //
            }
        } else {
            $userData = Arr::only(
                $request->input('user'),
                ['name', 'profile_image', 'self_introduction'],
            );
            $userData['email'] = uniqid() . '@localhost';
            $userData['password'] = 'dummy';
            $userData['profile_image'] ??= config('mnmn.default_image');

            DB::transaction(function () use ($user, $userData) {
                $createdUser = User::create($userData);
                Friendship::create([
                    'from' => $user->id,
                    'to' => $createdUser->id,
                ]);
            });
            $success = true;
        }

        return [
            'success' => $success,
        ];
    }

    /**
     * Remove a friend.
     */
    public function destroy(Request $request)
    {
        $user = \Auth::user();
        $request->validate([
            'user_id' => [
                'required',
            ],
        ]);

        $success = Friendship::where([
            'from' => $user->id,
            'to' => $request->input('user_id'),
        ])
            ->delete();

        return [
            'success' => $success > 0,
        ];
    }

    /**
     * Search users to be friends with.
     */
    public function search(Request $request)
    {
        $input = $request->validate([
            'name' => 'string',
        ]);

        $user = \Auth::user();
        $followingUserIds = Friendship::where('from', $user->id)
            ->select('to')
            ->get()
            ->map(fn ($row) => $row->to)
            ->toArray();

        $users = User::where('name', 'like', '%' . Utils::escapeLike($input['name']) . '%')
            ->where('id', '!=', $user->id)
            ->where('password', '!=', 'dummy')
            ->get();
        collect($users)
            ->each(function (&$user) use ($followingUserIds) {
                $user->is_following = in_array($user->id, $followingUserIds);
            });
        return [
            'items' => $users,
        ];
    }
}
