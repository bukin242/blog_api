class CreateUserPostIps < ActiveRecord::Migration[5.1]
  def up
    create_table :user_post_ips do |t|
      t.bigint :users_ids, array: true
      t.inet :ip
    end

    add_index :user_post_ips, :ip, unique: true
    add_index :user_post_ips, :users_ids, using: :gin

    execute File.read "#{Rails.root.to_s}/db/plpgsql/add_user_post.sql"
    execute File.read "#{Rails.root.to_s}/db/plpgsql/del_user_post.sql"
  end

  def down
    execute 'drop trigger if exists add_user_post_trigger on posts;'
    execute 'drop function if exists add_user_post() cascade;'
    execute 'drop trigger if exists del_user_post_trigger on posts;'
    execute 'drop function if exists del_user_post() cascade;'
    remove_index :user_post_ips, :ip
    remove_index :user_post_ips, :users_ids
    drop_table :user_post_ips
  end
end
