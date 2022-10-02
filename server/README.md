# mnmn

## インストール

```sh
cp .env.example .env
docker-compose up -d

# すべてのコンテナが正常に起動したことを確認し、以下に進んでください
# コンテナ内でLaravelのセットアップを行います
docker-compose exec php bash
composer install
php artisan key:generate
php artisan migrate
php artisan ide-helper:model --nowrite
php artisan storage:link
```

**🔧 すでにポートが使用されていてコンテナを起動できない場合**

`Bind for 0.0.0.0:3306 failed: port is already allocated` のようなエラーメッセージが表示されコンテナを起動できない場合、コンテナへの外部からのアクセス用のポート番号を変更する必要があります。
`.env` ファイルに以下のように追記を行い、 `docker-compose up -d` を実行してください。  
⚠ これらの設定はコンテナ間通信には影響しないことを注意してください (例: `php` コンテナから `mysql` コンテナにアクセスする場合、 `FORWARD_DB_PORT` の設定に関わらず常に 3306 番ポートを使用しアクセスします)。

```
# 変更する必要のあるポート番号のみ、追記すること
FORWARD_DB_PORT=****
FORWARD_MAILHOG_PORT=****
FORWARD_MAILHOG_DASHBOARD_PORT=****
FORWARD_NGINX_PORT=****
```

### ダミーデータの作成

`docker-compose exec php php artisan db:seed --class Database\Seeders\Dev\DevDatabaseSeeder` (`\` のエスケープが必要な場合あり)

作成されるデータは、 [`database\seeders\Dev`](database/seeders/Dev) フォルダで定義されています。

**テストユーザアカウント**

| メールアドレス     | パスワード  | コメント                                                                         |
| ------------------ | ----------- | -------------------------------------------------------------------------------- |
| `dev1@example.com` | `password1` | `dev1` ～ `dev4` の 4 アカウントが存在<br>パスワードの数値はメールアドレスに一致 |

**管理ユーザアカウント**

| メールアドレス    | パスワード | コメント |
| ----------------- | ---------- | -------- |
| `admin@localhost` | `password` |          |

## マイグレーション

`database/migrations` フォルダに変更が加えられた際は、以下のコマンドを実行し変更内容が入力補完で利用できるよう、クラス定義コードの再生成を行います。

```
docker-compose exec php php artisan ide-helper:model --nowrite
```

## システム構成

| サービス名 | デフォルト URL                                       | 説明                                                                                                                   | 使用ポート     |
| ---------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------------- |
| mailhog    | http://localhost:8025                                | 開発用の SMTP サーバです。メール送信を伴う処理を実装する場合、送信メールを mailhog 上で閲覧することができます。        | `1025`, `8025` |
| mysql      | `mysql://mysql:secret@localhost:3306/mnmn`           | データベースサーバです。他のコンテナからアクセスする場合、 `localhost` ではなく `mysql` を使用して名前解決を行います。 | `3306`         |
| nginx      | http://localhost<br>http://localhost/nova (管理画面) | HTTP サーバです。 `*.php` ファイルへのアクセスの場合、リクエストを `php` コンテナに転送し処理します。                  | `80`           |
| php        |                                                      | PHP 実行用コンテナです。 `artisan` コマンドを実行する場合、このコンテナ内で実行してください。                          | (なし)         |
