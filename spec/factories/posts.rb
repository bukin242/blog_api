FactoryGirl.define do
  factory :post do
    user_id 1
    ip '111.111.111.111'
    sequence(:title) {|n| "Hello #{n}" }
    sequence(:description) {|n| "Description #{n}" }
  end
end
