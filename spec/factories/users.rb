FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'user@example.com'
    permissions { ['signin'] }
  end
end
