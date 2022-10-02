@extends('layout')
@section('content')

<div class="align-self-center">

@if (isset($invalidToken) && $invalidToken)
    <div class="alert alert-danger" role="alert">
        トークンが期限切れ、または有効ではありません。アプリより再度パスワードリセットメールを送信してください。
    </div>
@elseif (isset($success) && $success)
    <div class="alert alert-success" role="alert">
        パスワードの再設定を完了いたしました。アプリより新しいパスワードでログインしてください。
    </div>
@else
    @if ($errors->any())
        <div class="alert alert-danger mb-4" role="alert">
            @foreach ($errors->all() as $error)
                <div>{{ $error }}</div>
            @endforeach
        </div>
    @endif

    <div class="card card-outline-secondary">
        <div class="card-header pt-3 pb-3">
            <h2 class="mb-0 fs-5">パスワードの再設定</h2>
        </div>
        <div class="card-body">
            <form class="form" role="form" autocomplete="off" method="POST">
                @csrf
                <input type="hidden" name="token" value="{{ app('request')->input('token') }}">
                <input type="hidden" name="email" value="{{ old('email') }}">

                <div class="form-group">
                    <label for="new-password">新しいパスワード</label>
                    <input id="new-password" name="new_password" type="password" class="form-control" required>
                </div>
                <div class="form-group mt-4">
                    <label for="new-password-confirmation">新しいパスワード (確認)</label>
                    <input id="new-password-confirmation" name="new_password_confirmation" type="password" class="form-control" required>
                </div>

                <div class="mt-5">
                    <button type="submit" class="btn btn-success w-100">決定</button>
                </div>
            </form>
        </div>
    </div>
@endif

</div>

@endsection
