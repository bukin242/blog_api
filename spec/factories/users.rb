FactoryGirl.define do
  factory :user do
    sequence(:login) {|n| "username_#{n}" }
  end
end
