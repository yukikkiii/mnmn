<?php

namespace App\Http\Controllers;

use App\Enums\MessageStatus;
use App\Helpers\Utils;
use App\Helpers\ValidationRules;
use App\Models\Message;
use App\Models\PraySite;
use App\Models\User;
use App\Models\UserLocation;
use Auth;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Storage;
use Validator;

class MessageController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        $messages = Message::orderBy('id', 'desc')
            ->where('messages.to', $user->id)
            ->where('messages.status', '!=', MessageStatus::DRAFT)
            ->with('user', 'fromUser', 'toUser')
            ->get();

        // TODO: pagination
        return [
            'success' => true,
            'items' => $messages,
        ];
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        $request->validate([
            'draft' => 'boolean|required',
            'draft_id' => 'nullable|int|exists:messages,id',
            'data.items' => 'array|required',
            'to_user_id' => 'int|required',
            'is_pray_site' => 'nullable|boolean',
            'note' => 'nullable|string|max:100',
        ]);

        $isPraySite = $request->has('is_pray_site');
        if (!$isPraySite) {
            // 過去に訪れた場所への設置時
            $request->validate(array_merge(
                ['receive_radius' => 'int|min:100|max:500'],
                ValidationRules::latLong(),
            ));
        }

        $user = Auth::user();
        $toUser = User::find($request->input('to_user_id'));

        $data = $request->input('data');
        $draft = $request->input('draft');

        // Generate text
        /** @var string */
        $text = null;
        foreach ($data['items'] as &$item) {
            switch ($item['type']) {
                case 'Image':
                    if (array_key_exists('imageBytes', $item)) {
                        $image = base64_decode($item['imageBytes']);
                        $filename = uniqid();
                        $path = "story-images/$filename";
                        Storage::disk('public')->put($path, $image);
                        unset($item['imageBytes']);
                        $item['imageUrl'] = Storage::url($path);
                    }
                    break;
                case 'Text':
                    $text = mb_substr($item['value'], 0, config('database.DEFAULT_STRING_LENGTH'));
                    break;
            }
        }

        Utils::sendNotification('まにまに', $user->name . 'さんからまにまにが届いています', $toUser);

        $messageArr = array_merge(
            $request->only('note', 'receive_radius'),
            [
                'data' => $data,
                'text' => $text,
                'from' => $user->id,
                'to' => $toUser->id,
                'status' => $draft ? MessageStatus::DRAFT : MessageStatus::UNOPENED,
            ],
        );

        if ($isPraySite) {
            $messageArr['receive_radius'] = 0;
        } else {
            $lat = $request->input('lat');
            $long = $request->input('long');
            $point = "POINT($long, $lat)";
            $messageArr['location'] = DB::raw($point);
        }

        $draftId = $request->input('draft_id');
        if ($draftId !== null) {
            $message = Message::find($draftId);
            $message->update($messageArr);
        } else {
            Message::create($messageArr);
        }

        return [
            'success' => true,
        ];
    }

    /**
     * Toggle favorite
     */
    public function favorite(Request $request, int $id)
    {
        $routeName = $request->route()->getName();
        $unfavorite = str_ends_with($routeName, 'unfavorite');

        $message = Message::findOrFail($id);
        $message->update([
            'is_favorite' => !$unfavorite,
        ]);

        return [
            'success' => true,
        ];
    }

    /**
     * Retrieve message at current location.
     */
    public function retrieve(Request $request)
    {
        $input = $request->only('lat', 'long', 'id', 'pray_site_id');
        // Warning: potential SQL injection without this validation
        $validator = Validator::make($input, ValidationRules::latLong());
        $validator->sometimes(
            'id',
            'exists:messages,id',
            fn ($input) => $request->has('id'),
        );
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors(),
            ];
        }

        $lat = $input['lat'];
        $long = $input['long'];
        $point = "POINT($long, $lat)";
        $user = Auth::user();

        /** @var Message|null */
        $id = array_key_exists('id', $input)
            ? $input['id']
            : null;
        if ($id === null) {
            $praySite = PraySite::whereRaw("st_distance_sphere(pray_sites.point, $point) <= pray_sites.radius")
                ->find($input['pray_site_id']);
            if ($praySite === null) {
                return [
                    'success' => false,
                    'code' => 'NO_PRAY_SITE',
                ];
            }
        }

        $messageQuery = Message::where('to', $user->id)
            ->whereRaw('messages.created_at < DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 WEEK)')
            ->where('status', '!=', MessageStatus::DRAFT)
            ->whereNull('received_at');
        if ($id) {
            $message = $messageQuery
                ->whereRaw("st_distance_sphere(messages.location, $point) <= messages.receive_radius")
                ->find($id);
            $messages = [];
            if ($message !== null) {
                $messages[] = $message;
            }
        } else {
            $messages = $messageQuery
                ->where('receive_radius', 0)
                ->get();
        }

        if (count($messages) === 0) {
            return [
                'success' => false,
                'code' => 'NO_MESSAGE',
            ];
        }

        $updatedCount = 0;
        foreach ($messages as $message) {
            if ($message->update([
                'received_at' => new Carbon(),
            ])) {
                $updatedCount++;
            }
        }
        return [
            'success' => $updatedCount > 0,
            'count' => $updatedCount,
        ];
    }

    /**
     * Open a sealed message.
     */
    public function open(int $id)
    {
        $user = Auth::user();
        $message = Message::where('to', $user->id)
            ->where('status', '!=', MessageStatus::DRAFT)
            ->findOrFail($id);

        $updated = $message->update([
            'status' => MessageStatus::SENT,
        ]);
        return [
            'success' => $updated,
        ];
    }

    /**
     * List sent messages for current user.
     */
    public function listSentMessages()
    {
        $user = Auth::user();

        // TODO: pagination
        $messages = Message::where('from', $user->id)
            ->with('user', 'toUser')
            ->orderByDesc('id')
            ->paginate(10);

        return array_merge(
            ['success' => true],
            Utils::paginatorToArray($messages),
        );
    }

    public function unread(Request $request)
    {
        $user = Auth::user();
        $messages = Message::where('to', $user->id)
            ->whereRaw('messages.created_at < DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 WEEK)')
            ->where('status', '!=', MessageStatus::DRAFT)
            ->whereNull('received_at')
            ->whereNull('deleted_at')
            ->with('user', 'fromUser', 'toUser')
            ->get();
        $messageCollection = collect($messages);
        $items = $messageCollection
            ->filter(fn ($message) => $message['receive_radius'] !== 0);
        return [
            'success' => true,
            'count' => count($messages),
            'items' => $items->toArray(),
            'pray_site_messages' => count($messages) - $items->count(),
        ];
    }

    /**
     * Display the specified resource.
     */
    public function show(int $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(int $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, int $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(int $id)
    {
        //
    }
}
