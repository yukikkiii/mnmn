<?php

namespace App\Jobs;

use App\Models\EmailUpdateRequest;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Mail\Mailable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Mail\Message;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Mail;
use Str;

class UpdateEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    private User $user;
    private string $newEmail;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct(User $user, string $newEmail)
    {
        $this->user = $user;
        $this->newEmail = $newEmail;
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        \Log::debug('メールアドレス変更メール送信開始', ['user_id' => $this->user->id, 'newEmail' => $this->newEmail]);

        $token = Str::random(64);
        EmailUpdateRequest::create([
            'user_id' => $this->user->id,
            'new_email' => $this->newEmail,
            'token' => $token,
        ]);
        $link = route(
            'email.update',
            ['token' => $token],
        );

        $body = <<<BODY
メールアドレスの変更を完了するには、次のリンクを開いてください。

    $link

もし本メールにお心当たりのない場合、破棄して頂きますようお願いいたします。
BODY;
        Mail::raw($body, function (Message $message) {
            $message
                ->to($this->newEmail)
                ->subject('メールアドレス変更を完了してください');
        });

        \Log::debug('メールアドレス変更メール送信完了');
    }
}
