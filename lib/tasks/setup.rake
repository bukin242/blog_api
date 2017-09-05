namespace :setup do
  desc 'Первоначальная настройка проекта'
  task :init do

    puts 'Please wait.'
    `rails db:create`
    `RAILS_ENV=development rails db:migrate`
    `RAILS_ENV=test rails db:migrate`
    `rails s --daemon`
    `rails db:seed`
    `kill $(lsof -i :3000 -t)`
    puts 'Done.'

  end
end
