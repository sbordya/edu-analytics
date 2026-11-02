#!/bin/bash
set -e

echo "=== 1. Starting Metabase in background ==="
/app/run_metabase.sh &

echo "=== 2. Waiting for Metabase HTTP API to become healthy ==="
# Цикл опрашивает локальный эндпоинт Metabase. 
# Как только миграции закончатся, API оживет.
until [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)" -eq 200 ]; do
  echo "Metabase is starting up or migrating... checking again in 3 seconds"
  sleep 3
done

echo "=== 3. Metabase is fully ready! Running custom migrations ==="
# Ставим psql-клиент прямо перед выполнением (или используем альтернативу)
apk update && apk add --no-cache postgresql-client jq

for sql_file in /scripts/migrations/*.sql; do
  [ -e "$sql_file" ] || continue
  echo "Executing: $(basename "$sql_file")..."
  PGPASSWORD="$MB_DB_PASS" psql -h "$MB_DB_HOST" -U "$MB_DB_USER" -d "$MB_DB_DBNAME" -f "$sql_file"
done

echo "=== 4. Checking if Admin user already exists ==="
# 1. Получаем временный сессионный токен настройки, который Metabase генерирует при старте
SETUP_TOKEN=$(curl -s http://localhost:3000/api/session/properties | jq -r '.["setup-token"]')

# 2. Отправляем официальный запрос на создание первого администратора
# Пароль должен быть не менее 6 символов и содержать минимум 1 цифру
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$SETUP_TOKEN\",
    \"user\": {
      \"email\": \"test@test.com\",
      \"first_name\": \"Test\",
      \"last_name\": \"Test\",
      \"password\": \"metabase1\"
    },
    \"prefs\": {
      \"site_name\": \"My Metabase BI\",
      \"allow_tracking\": false
    }
  }" \
  http://localhost:3000/api/setup
  
echo -e "\n=== Admin user created successfully via API! ==="

echo "=== 5. Custom migrations applied successfully! ==="
wait
