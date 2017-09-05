with users_shifted_ids as ( -- сдвинем оригинальный id чтобы потом сравнить повторяются ли group_id
  select (id + 1) as id, group_id from users
),
suitable_groups as (
  select
    users.id,
    users.group_id,
    coalesce(users_shifted_ids.group_id, users.group_id) as shifted_group_id -- в первой строке сдвинутый group_id = <null> заменяем на оригинальный
  from users
  left join users_shifted_ids on users.id = users_shifted_ids.id
)
select
  min(id) as min_id,
  group_id,
  count(group_id)

from suitable_groups
group by group_id, shifted_group_id
order by min_id asc
