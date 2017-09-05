drop function if exists del_user_post() cascade;
create or replace function del_user_post() returns trigger as
$$
  begin
    if old.ip is not null and (select count(*) from posts where posts.ip = old.ip and posts.user_id = old.user_id) < 1 then
      update user_post_ips set users_ids = array_remove(users_ids, old.user_id)
        where user_post_ips.ip = old.ip and (user_post_ips.users_ids @> array[old.user_id])
      ;
    end if;

    return new;
  end
$$ language plpgsql;

comment on function del_user_post() is 'При удалении поста пользователь убирается из списка ip в логах но только если у него нет больше постов с этим ip';

create trigger del_user_post_trigger after delete on posts for each row execute procedure del_user_post();
