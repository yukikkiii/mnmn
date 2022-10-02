docker-compose exec php php artisan migrate:fresh
docker-compose exec php php artisan db:seed --class Database\Seeders\Dev\DevDatabaseSeeder
docker-compose exec php php artisan ide-helper:model --nowrite
