<?php

namespace App\Helpers;

use App\Models\User;
use Arr;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\ServiceAccount;

class Utils
{
    public static function paginatorToArray(LengthAwarePaginator $paginator): array
    {
        $data = $paginator->toArray();

        return [
            'items' => $data['data'],
            'pagination' => Arr::only($data, ['current_page', 'from', 'last_page', 'per_page', 'to', 'total']),
        ];
    }

    public static function escapeLike(string $pattern)
    {
        return addcslashes($pattern, '%_\\');
    }

    /**
     * @param User|User[] $to
     */
    public static function sendNotification($title, $body, $to = null): bool
    {
        $serviceAccount = ServiceAccount::fromValue(base_path() . '/service-account.json');
        $firebase = (new Factory)
            ->withServiceAccount($serviceAccount);
        $messaging = $firebase->createMessaging();

        $notification = Notification::fromArray([
            'title' => $title,
            'body' => $body,
        ]);

        $message = CloudMessage::new()->withNotification($notification)
            ->withAndroidConfig(
                AndroidConfig::new()
                    ->withHighPriority()
            );

        $sent = false;
        if ($to) {
            if (!is_array($to)) {
                $to = [$to];
            }
            $tokens = array_filter(array_map(fn($user) => $user->fcm_token, $to));
            if (!empty($tokens)) {
                $messaging->sendMulticast($message, array_map(fn($user) => $user->fcm_token, $to));
                $sent = true;
            }
        } else {
            $messaging->sendAll($message);
            $sent = true;
        }

        \Log::debug(
            'Sent notification',
            [
                'sent' => $sent,
                'to' => $to ? array_map(fn ($user) => $user->id, $to) : null,
                'tokens_count' => $to ? count($tokens) : null,
            ],
        );

        return $sent;
    }
}
