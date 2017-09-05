drop function if exists add_user_post() cascade;
create or replace function add_user_post() returns trigger as
$$
  begin
    if new.ip is not null then
      insert into user_post_ips(ip, users_ids) values(new.ip, array[new.user_id])
        on conflict (ip) do -- если ip уже существует то мы просто добавляем к массиву user_id, в противном случае создаем новую запись
          update set users_ids = array_append(user_post_ips.users_ids, new.user_id)
          where not (user_post_ips.users_ids @> array[new.user_id]) -- только если user_id еще не находится в массиве
      ;
    end if;

    return new;
  end
$$ language plpgsql;

comment on function add_user_post() is 'При создании нового поста ip и пользователь логгируется в user_post_ips';

create trigger add_user_post_trigger after insert on posts for each row execute procedure add_user_post();
