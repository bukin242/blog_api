# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'

ActiveRecord::Base.connection.execute("TRUNCATE users RESTART IDENTITY CASCADE")
ActiveRecord::Base.connection.execute("TRUNCATE posts RESTART IDENTITY CASCADE")
ActiveRecord::Base.connection.execute("TRUNCATE user_post_ips RESTART IDENTITY CASCADE")

create_path = 'http://127.0.0.1:3000%s' % Rails.application.routes.url_helpers.public_api_posts_path
users = (1..100).map{ Faker::Name.unique.first_name.downcase }
ips = (1..50).map{ Faker::Internet.ip_v4_address }
posts = (1..2000).map{ [Faker::Lorem.sentence(3), Faker::Lorem.paragraph(3)] }

begin

  posts.each do |title, description|
    params = {
      title: title,
      description: description,
      login: users.sample,
      ip: ips.sample
    }

    RestClient.post create_path, params.to_json, {content_type: :json, accept: :json}
  end

  # 100 постам присваевается от 1 до 10 оценок от 1 до 5
  Post.order("RANDOM()").limit(100).pluck(:id).each do |post_id|
    Array.new(rand(1..10)) { rand(1..5) }.each do |rating_value|
      RestClient.put create_path, {id: post_id, rating_value: rating_value}.to_json, {content_type: :json, accept: :json}
    end
  end

rescue Errno::ECONNREFUSED
  puts 'Нужно запустить rails server!'
end
