@extends('layout')
@section('content')

<div class="align-self-center">

<div class="alert alert-success" role="alert">
    メールアドレスの再設定を完了しました。<br>
    引き続き {{ config('app.name') }} のご利用をお楽しみください。
</div>

</div>

@endsection
