#!/bin/bash

# Получаем список запущенных контейнеров
containers=$(docker ps --format '{{.Names}}')

# Проверяем, есть ли контейнеры
if [ -z "$containers" ]; then
    echo "Нет запущенных контейнеров."
    exit 1
fi

# Выводим список контейнеров с номерами
echo "Выберите контейнер из списка:"
select container_name in $containers; do
    if [ -n "$container_name" ]; then
        break
    else
        echo "Выберите корректный номер."
    fi
done

# Запрашиваем имя файла дампа
read -p "Введите имя файла дампа (без пути, файл должен находиться в /root/): " dump_file_name

# Проверяем, существует ли файл дампа
dump_file="/root/$dump_file_name"
if [ ! -f "$dump_file" ]; then
    echo "Файл дампа не найден в /root/. Пожалуйста, укажите корректное имя файла."
    exit 1
fi

# Получаем путь до контейнера
container_path=$(docker inspect -f '{{ index .Mounts 0 "Source" }}' "$container_name")

# Восстанавливаем дамп в MySQL
echo "Восстановление дампа в базу данных в контейнере $container_name..."
docker exec -i "$container_name" mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$dump_file"

echo "Дамп успешно восстановлен в базу данных в контейнере $container_name."
