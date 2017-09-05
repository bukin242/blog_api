# Blog Json Api
  * Ruby version 2.4.1
  * Rails version 5.1.3

## Разворачивание
  1. Переименовать config/database.yml.sample в config/database.yml и прописать своего пользователя.
  2. rails setup:init создаст БД и заполнит тестовыми данными.

## URL
  1. [GET]  /public_api/posts - рейтинг top N принимает необязательный параметр ?top=N где N макс. кол-во записей в топе.
  2. [POST] /public_api/posts - создание поста.
  3. [PUT]  /public_api/posts - поставить оценку посту.
  4. [GET]  /public_api/posts/ips_different_authors - список IP с которых постило несколько разных авторов.

## Sql
  * Решение задачки по sql в файле: group_ids.sql
